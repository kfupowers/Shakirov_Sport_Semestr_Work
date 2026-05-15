package ru.kpfu.itis.shakirov.service;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.hibernate.Hibernate;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.kpfu.itis.shakirov.dto.CompetitionDto;
import ru.kpfu.itis.shakirov.dto.CompetitionRequest;
import ru.kpfu.itis.shakirov.dto.CompetitionViewDto;
import ru.kpfu.itis.shakirov.entity.*;
import ru.kpfu.itis.shakirov.mapper.CompetitionMapper;
import ru.kpfu.itis.shakirov.repository.CompetitionCriteriaRepository;
import ru.kpfu.itis.shakirov.repository.CompetitionRepository;
import ru.kpfu.itis.shakirov.repository.DisciplineRepository;
import ru.kpfu.itis.shakirov.repository.MatchRepository;
import ru.kpfu.itis.shakirov.repository.ParticipationRepository;
import ru.kpfu.itis.shakirov.repository.TeamMemberRepository;
import ru.kpfu.itis.shakirov.api.generated.dto.CompetitionResponse;
import ru.kpfu.itis.shakirov.security.AccountUserDetails;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class CompetitionService {
    private final AddressService addressService;
    private final CompetitionRepository competitionRepo;
    private final CompetitionCriteriaRepository criteriaRepo;
    private final DisciplineRepository disciplineRepo;
    private final CompetitionMapper competitionMapper;
    private final TeamService teamService;
    private final ParticipationService participationService;
    private final MatchService matchService;
    private final AccountService accountService;
    private final ParticipationRepository participationRepository;
    private final TeamMemberRepository teamMemberRepository;
    private final MatchRepository matchRepository;

    private static final Comparator<Competition> STATUS_ORDER_COMPARATOR = Comparator
            .comparingInt((Competition c) -> {
                if (c.getStatus() == CompetitionStatus.OPEN) return 0;
                if (c.getStatus() == CompetitionStatus.IN_PROGRESS) return 1;
                if (c.getStatus() == CompetitionStatus.COMPLETED) return 2;
                return 3;
            })
            .thenComparing(Competition::getDatetime);

    private CompetitionStatus parseStatus(String status) {
        if (status == null || status.isBlank()) return null;
        try {
            return CompetitionStatus.valueOf(status.toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    @Transactional(readOnly = true)
    public List<Competition> findAll() {
        List<Competition> competitions = competitionRepo.findAll();
        competitions.sort(STATUS_ORDER_COMPARATOR);
        return competitions;
    }

    @Transactional
    @CacheEvict(value = {"competitionDto", "competitionResponse", "competitionDtoList", "competitionResponseList"}, allEntries = true)
    public void deleteByAdmin(Long id) {
        competitionRepo.deleteById(id);
    }

    @Cacheable(value = "competitionDtoList", key = "{#disciplineName, #status, #city}")
    @Transactional(readOnly = true)
    public List<CompetitionDto> findDtosByFilters(String disciplineName, String status, String city) {
        CompetitionStatus competitionStatus = parseStatus(status);
        List<Competition> comps = criteriaRepo.findByFilters(disciplineName, competitionStatus, city);
        comps.sort(STATUS_ORDER_COMPARATOR);
        return competitionMapper.toDtoList(comps);
    }

    @Cacheable(value = "competitionResponseList", key = "{#disciplineName, #status, #city}")
    @Transactional(readOnly = true)
    public List<CompetitionResponse> findResponsesByFilters(String disciplineName, String status, String city) {
        CompetitionStatus competitionStatus = parseStatus(status);
        List<Competition> comps = criteriaRepo.findByFilters(disciplineName, competitionStatus, city);
        comps.sort(STATUS_ORDER_COMPARATOR);
        return competitionMapper.toResponseList(comps);
    }

    @Transactional(readOnly = true)
    public CompetitionViewDto getViewDto(Long id, AccountUserDetails user) {
        Competition comp = competitionRepo.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Competition not found"));
        Hibernate.initialize(comp.getDiscipline());
        Hibernate.initialize(comp.getOwner());
        Hibernate.initialize(comp.getMatches());
        Hibernate.initialize(comp.getParticipations());
        comp.getParticipations().forEach(p -> Hibernate.initialize(p.getTeam()));

        List<Team> userTeams = teamService.getActiveTeamsByCaptain(user.getId());
        List<Participation> participations = participationService.findByCompetitionId(id);
        participations.sort(Comparator.comparing(Participation::getPlace,
                        Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(p -> p.getTeam().getName()));
        List<Match> matches = matchService.findByCompetitionIdOrderByRoundAsc(id);
        for (Match m : matches) {
            Hibernate.initialize(m.getFirstTeam());
            Hibernate.initialize(m.getSecondTeam());
        }

        return CompetitionViewDto.builder()
                .competition(comp)
                .userTeams(userTeams)
                .participations(participations)
                .matches(matches)
                .formattedDatetime(comp.getDatetime().format(DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm")))
                .build();
    }

    @Cacheable(value = "competitionDto", key = "#id")
    @Transactional(readOnly = true)
    public CompetitionDto getDtoById(Long id) {
        Competition c = getById(id);
        return competitionMapper.toDto(c);
    }

    @Cacheable(value = "competitionResponse", key = "#id")
    @Transactional(readOnly = true)
    public CompetitionResponse getResponseById(Long id) {
        Competition c = getById(id);
        return competitionMapper.toResponse(c);
    }

    private Competition getById(Long id) {
        return competitionRepo.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Competition not found"));
    }

    @Transactional
    @CachePut(value = "competitionResponse", key = "#result.id")
    @CacheEvict(value = {"competitionDtoList", "competitionResponseList"}, allEntries = true)
    public CompetitionResponse createResponse(CompetitionRequest request, Account owner) {
        checkOrganizerOrAdmin(owner);
        Competition comp = createEntity(request, owner);
        return competitionMapper.toResponse(comp);
    }

    @Transactional
    @CacheEvict(value = {"competitionDtoList", "competitionResponseList"}, allEntries = true)
    public void create(CompetitionRequest request, Account owner) {
        checkOrganizerOrAdmin(owner);
        createEntity(request, owner);
    }

    private Competition createEntity(CompetitionRequest request, Account owner) {
        if (request.getAddress() != null && !request.getAddress().isBlank()) {
            if (!addressService.isValidAddress(request.getAddress())) {
                throw new IllegalArgumentException("Адрес не найден или недействителен");
            }
        }
        if (request.getDatetime().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Дата начала должна быть в будущем");
        }
        if (!isPowerOfTwo(request.getTournamentSize())) {
            throw new IllegalArgumentException("Tournament size must be a power of 2");
        }
        Discipline discipline = disciplineRepo.findById(request.getDisciplineId())
                .orElseThrow(() -> new EntityNotFoundException("Discipline not found"));
        ZonedDateTime zonedDatetime = request.getDatetime().atZone(ZoneId.systemDefault());
        Competition comp = Competition.builder()
                .title(request.getTitle())
                .datetime(zonedDatetime)
                .address(request.getAddress())
                .discipline(discipline)
                .owner(owner)
                .status(CompetitionStatus.OPEN)
                .tournamentSize(request.getTournamentSize())
                .requiredTeamSize(request.getRequiredTeamSize())
                .build();
        competitionRepo.save(comp);
        log.info("Competition '{}' created by {}", comp.getTitle(), owner.getLogin());
        return comp;
    }

    @Transactional
    @CachePut(value = "competitionResponse", key = "#id")
    @CacheEvict(value = {"competitionDtoList", "competitionResponseList"}, allEntries = true)
    public CompetitionResponse updateResponse(Long id, CompetitionRequest request, Account currentUser) {
        Competition comp = updateEntity(id, request, currentUser);
        return competitionMapper.toResponse(comp);
    }

    @Transactional
    @CachePut(value = "competitionDto", key = "#id")
    @CacheEvict(value = {"competitionDtoList", "competitionResponseList"}, allEntries = true)
    public void update(Long id, CompetitionRequest request, Account currentUser) {
        updateEntity(id, request, currentUser);
    }

    private Competition updateEntity(Long id, CompetitionRequest request, Account currentUser) {
        Competition comp = getById(id);
        if (request.getDatetime().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Дата начала должна быть в будущем");
        }
        if (request.getAddress() != null && !request.getAddress().isBlank()) {
            if (!addressService.isValidAddress(request.getAddress())) {
                throw new IllegalArgumentException("Адрес не найден или недействителен");
            }
        }
        if (!comp.getOwner().getId().equals(currentUser.getId()) &&
                currentUser.getRoles().stream().noneMatch(role -> role.getName().equals("ADMIN"))) {
            throw new AccessDeniedException("You are not allowed to edit this competition");
        }
        Discipline discipline = disciplineRepo.findById(request.getDisciplineId())
                .orElseThrow(() -> new EntityNotFoundException("Discipline not found"));
        comp.setTitle(request.getTitle());
        comp.setDatetime(request.getDatetime().atZone(ZoneId.systemDefault()));
        comp.setAddress(request.getAddress());
        comp.setDiscipline(discipline);
        return competitionRepo.save(comp);
    }

    @Transactional
    @CacheEvict(value = {"competitionDto", "competitionResponse", "competitionDtoList", "competitionResponseList"}, allEntries = true)
    public void delete(Long id, Account currentUser) {
        Competition comp = getById(id);
        if (!comp.getOwner().getId().equals(currentUser.getId()) &&
                currentUser.getRoles().stream().noneMatch(role -> role.getName().equals("ADMIN"))) {
            throw new AccessDeniedException("You are not allowed to delete this competition");
        }
        competitionRepo.deleteById(id);
        log.info("Competition {} deleted by {}", id, currentUser.getLogin());
    }

    @Transactional(readOnly = true)
    public CompetitionRequest getCompetitionRequestForEdit(Long id) {
        Competition comp = getById(id);
        CompetitionRequest req = new CompetitionRequest();
        req.setTitle(comp.getTitle());
        req.setDatetime(comp.getDatetime().toLocalDateTime());
        req.setAddress(comp.getAddress());
        req.setDisciplineId(comp.getDiscipline().getId());
        req.setTournamentSize(comp.getTournamentSize());
        req.setRequiredTeamSize(comp.getRequiredTeamSize());
        return req;
    }

    private void checkOrganizerOrAdmin(Account user) {
        boolean isOrganizerOrAdmin = user.getRoles().stream()
                .anyMatch(role -> role.getName().equals("ORGANIZER") || role.getName().equals("ADMIN"));
        if (!isOrganizerOrAdmin) {
            throw new AccessDeniedException("Only organizers or admins can create competitions");
        }
    }

    @Transactional
    @CacheEvict(value = {"competitionDto", "competitionResponse", "competitionDtoList", "competitionResponseList"}, allEntries = true)
    public void startTournament(Long competitionId, Account organizer) {
        Competition comp = getById(competitionId);

        if (!comp.getOwner().getId().equals(organizer.getId()) &&
                organizer.getRoles().stream().noneMatch(r -> r.getName().equals("ADMIN"))) {
            throw new AccessDeniedException("Only competition owner or admin can start tournament");
        }
        if (comp.getStatus() != CompetitionStatus.OPEN) {
            throw new IllegalStateException("Competition is not in OPEN state");
        }
        if (comp.getTournamentSize() == null || comp.getRequiredTeamSize() == null) {
            throw new IllegalStateException("Tournament size or required team size not set");
        }

        List<Participation> participations = participationRepository.findByCompetitionId(competitionId);
        if (participations.size() < 2) {
            throw new IllegalArgumentException("At least 2 teams are required to start a tournament");
        }
        if (participations.size() > comp.getTournamentSize()) {
            throw new IllegalArgumentException(
                    "Number of registered teams (" + participations.size() +
                            ") exceeds tournament size (" + comp.getTournamentSize() + ")");
        }

        for (Participation p : participations) {
            long memberCount = teamMemberRepository.countByTeamId(p.getTeam().getId());
            if (memberCount < comp.getRequiredTeamSize()) {
                throw new IllegalArgumentException(
                        "Team '" + p.getTeam().getName() + "' has only " +
                                memberCount + " members, but at least " + comp.getRequiredTeamSize() + " are required");
            }
        }

        matchRepository.deleteByCompetitionId(competitionId);

        List<Team> teams = participations.stream()
                .map(Participation::getTeam)
                .collect(Collectors.toList());

        comp.setStatus(CompetitionStatus.IN_PROGRESS);
        competitionRepo.save(comp);

        createBracket(comp, teams);
    }

    private void createBracket(Competition comp, List<Team> teams) {
        int totalSlots = nextPowerOfTwo(teams.size());
        List<Team> slots = new ArrayList<>(teams);
        while (slots.size() < totalSlots) {
            slots.add(null);
        }
        Collections.shuffle(slots);

        int total = slots.size();
        int rounds = (int) (Math.log(total) / Math.log(2));
        if (Math.pow(2, rounds) != total) {
            throw new IllegalArgumentException("Tournament size must be a power of 2");
        }

        List<Match> currentRoundMatches = new ArrayList<>();
        for (int i = 0; i < total; i += 2) {
            Team team1 = slots.get(i);
            Team team2 = slots.get(i + 1);

            Match match = Match.builder()
                    .competition(comp)
                    .round(1)
                    .firstTeam(team1)
                    .secondTeam(team2)
                    .build();

            if (team1 == null && team2 != null) {
                match.setWinnerTeam(team2);
            } else if (team2 == null && team1 != null) {
                match.setWinnerTeam(team1);
            }

            currentRoundMatches.add(matchRepository.save(match));
        }

        List<Match> previousRound = currentRoundMatches;
        for (int round = 2; round <= rounds; round++) {
            List<Match> newRound = new ArrayList<>();
            for (int i = 0; i < previousRound.size(); i += 2) {
                Match nextMatch = Match.builder()
                        .competition(comp)
                        .round(round)
                        .build();
                nextMatch = matchRepository.save(nextMatch);
                previousRound.get(i).setNextMatch(nextMatch);
                previousRound.get(i + 1).setNextMatch(nextMatch);
                matchRepository.save(previousRound.get(i));
                matchRepository.save(previousRound.get(i + 1));
                newRound.add(nextMatch);
            }
            previousRound = newRound;
        }

        for (Match match : currentRoundMatches) {
            if (match.getWinnerTeam() != null && match.getNextMatch() != null) {
                promoteWinner(match.getWinnerTeam(), match.getNextMatch());
            }
        }
    }

    private void promoteWinner(Team winner, Match nextMatch) {
        if (nextMatch.getFirstTeam() == null) {
            nextMatch.setFirstTeam(winner);
        } else if (nextMatch.getSecondTeam() == null) {
            nextMatch.setSecondTeam(winner);
        }
        matchRepository.save(nextMatch);
    }

    private int nextPowerOfTwo(int n) {
        if (n <= 0) return 1;
        int power = 1;
        while (power < n) {
            power <<= 1;
        }
        return power;
    }

    private boolean isPowerOfTwo(int n) {
        return n > 0 && (n & (n - 1)) == 0;
    }
}