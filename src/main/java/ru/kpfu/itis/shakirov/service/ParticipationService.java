package ru.kpfu.itis.shakirov.service;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.kpfu.itis.shakirov.entity.*;
import ru.kpfu.itis.shakirov.repository.CompetitionRepository;
import ru.kpfu.itis.shakirov.repository.ParticipationRepository;
import ru.kpfu.itis.shakirov.repository.TeamRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ParticipationService {
    private final ParticipationRepository participationRepo;
    private final TeamRepository teamRepo;
    private final CompetitionRepository competitionRepo;

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

        Participation p = Participation.builder()
                .competition(comp)
                .team(team)
                .build();
        return participationRepo.save(p);
    }

    @Transactional(readOnly = true)
    public List<Participation> findByCompetitionId(Long competitionId) {
        return participationRepo.findByCompetitionId(competitionId);
    }
}