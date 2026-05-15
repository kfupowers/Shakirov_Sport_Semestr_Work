package ru.kpfu.itis.shakirov.service;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.hibernate.Hibernate;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.kpfu.itis.shakirov.entity.*;
import ru.kpfu.itis.shakirov.repository.*;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ParticipationService {
    private final ParticipationRepository participationRepo;
    private final TeamRepository teamRepo;
    private final CompetitionRepository competitionRepo;
    private final TeamMemberRepository teamMemberRepository;
    private final MatchRepository matchRepository;

    @Transactional
    public Participation registerTeam(Long competitionId, Long teamId, Account currentUser) {
        Team team = teamRepo.findById(teamId)
                .orElseThrow(() -> new EntityNotFoundException("Team not found"));
        Competition comp = competitionRepo.findById(competitionId)
                .orElseThrow(() -> new EntityNotFoundException("Competition not found"));

        if (comp.getStatus() != CompetitionStatus.OPEN) {
            throw new IllegalStateException("Competition is not open for registration");
        }
        if (!team.getCaptain().getId().equals(currentUser.getId())) {
            throw new AccessDeniedException("Only team captain can register a team");
        }
        if (participationRepo.existsByTeamIdAndCompetitionId(teamId, competitionId)) {
            throw new IllegalStateException("Team already registered");
        }

        if (comp.getTournamentSize() != null) {
            long currentCount = participationRepo.countByCompetitionId(competitionId);
            if (currentCount >= comp.getTournamentSize()) {
                throw new IllegalStateException(
                        "Достигнуто максимальное количество команд (" + comp.getTournamentSize() + ")");
            }
        }

        if (comp.getRequiredTeamSize() != null && comp.getRequiredTeamSize() > 0) {
            long memberCount = teamMemberRepository.countByTeamId(teamId);
            if (memberCount < comp.getRequiredTeamSize()) {
                throw new IllegalStateException(
                        "В команде недостаточно участников. Требуется минимум " +
                                comp.getRequiredTeamSize() + ", сейчас " + memberCount
                );
            }
        }

        List<Account> members = teamMemberRepository.findAccountsByTeamId(teamId);
        List<Participation> existingParticipations =
                participationRepo.findByCompetitionId(competitionId);

        for (Account member : members) {
            for (Participation p : existingParticipations) {
                if (teamMemberRepository.existsByTeamIdAndAccountId(p.getTeam().getId(), member.getId())) {
                    throw new IllegalStateException(
                            "User '" + member.getLogin() + "' is already participating in this competition with another team"
                    );
                }
            }
        }

        Participation p = Participation.builder()
                .competition(comp)
                .team(team)
                .build();
        return participationRepo.save(p);
    }

    @Transactional
    public void unregisterTeam(Long competitionId, Long teamId, Account currentUser) {
        Team team = teamRepo.findById(teamId)
                .orElseThrow(() -> new EntityNotFoundException("Team not found"));
        Competition comp = competitionRepo.findById(competitionId)
                .orElseThrow(() -> new EntityNotFoundException("Competition not found"));

        if (comp.getStatus() != CompetitionStatus.OPEN) {
            throw new IllegalStateException("Cannot withdraw from a tournament that is not in OPEN state");
        }
        if (!team.getCaptain().getId().equals(currentUser.getId())) {
            throw new AccessDeniedException("Only team captain can withdraw the team");
        }

        Participation participation = participationRepo
                .findByCompetitionIdAndTeamId(competitionId, teamId)
                .orElseThrow(() -> new IllegalStateException("Team is not registered for this competition"));
        participationRepo.delete(participation);
    }

    @Transactional(readOnly = true)
    public List<Participation> findByCompetitionId(Long competitionId) {
        return participationRepo.findByCompetitionId(competitionId);
    }

    @Transactional(readOnly = true)
    public List<Participation> findByAccountId(Long accountId) {
        List<Participation> participations = participationRepo.findByMemberAccountId(accountId);
        for (Participation p : participations) {
            Hibernate.initialize(p.getCompetition());
            Hibernate.initialize(p.getTeam());
        }
        return participations;
    }

    @Transactional
    public void calculatePlaces(Competition competition) {
        List<Participation> participations = participationRepo.findByCompetitionId(competition.getId());
        List<Match> matches = matchRepository.findByCompetitionIdOrderByRoundAsc(competition.getId());

        int totalRounds = matches.stream().mapToInt(Match::getRound).max().orElse(0);
        if (totalRounds == 0) return;

        for (Participation p : participations) {
            Long teamId = p.getTeam().getId();

            Match lastMatch = null;
            int maxRound = 0;
            for (Match m : matches) {
                if (m.getFirstTeam() != null && m.getFirstTeam().getId().equals(teamId)
                        || m.getSecondTeam() != null && m.getSecondTeam().getId().equals(teamId)) {
                    if (m.getRound() > maxRound) {
                        maxRound = m.getRound();
                        lastMatch = m;
                    }
                }
            }

            if (lastMatch == null) {
                p.setPlace(null);
            } else if (lastMatch.getRound() == totalRounds && lastMatch.getWinnerTeam() != null
                    && lastMatch.getWinnerTeam().getId().equals(teamId)) {
                p.setPlace(1);
            } else if (lastMatch.getRound() == totalRounds) {
                p.setPlace(2);
            } else {
                int place = (int) Math.pow(2, totalRounds - lastMatch.getRound()) + 1;
                p.setPlace(place);
            }

            participationRepo.save(p);
        }
    }
}