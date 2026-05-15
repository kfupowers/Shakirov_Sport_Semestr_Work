package ru.kpfu.itis.shakirov.service;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.kpfu.itis.shakirov.entity.*;
import ru.kpfu.itis.shakirov.repository.*;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MatchService {

    private final MatchRepository matchRepository;
    private final TeamRepository teamRepository;
    private final CompetitionRepository competitionRepository;
    private final ParticipationService participationService;

    @Transactional(readOnly = true)
    public List<Match> findByCompetitionIdOrderByRoundAsc(Long competitionId) {
        return matchRepository.findByCompetitionIdOrderByRoundAsc(competitionId);
    }

    @Transactional
    public void setResult(Long competitionId, Long matchId, int score1, int score2,
                          Long winnerTeamId, Account currentUser) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new EntityNotFoundException("Match not found"));

        if (!match.getCompetition().getId().equals(competitionId)) {
            throw new IllegalArgumentException("Match does not belong to competition");
        }

        Competition competition = match.getCompetition();
        if (!competition.getOwner().getId().equals(currentUser.getId()) &&
                currentUser.getRoles().stream().noneMatch(r -> r.getName().equals("ADMIN"))) {
            throw new AccessDeniedException("Only organizer or admin can set results");
        }

        if (match.getWinnerTeam() != null) {
            throw new IllegalStateException("Match already has a result");
        }

        if (winnerTeamId == null) {
            if (score1 > score2) {
                winnerTeamId = match.getFirstTeam().getId();
            } else if (score2 > score1) {
                winnerTeamId = match.getSecondTeam().getId();
            } else {
                throw new IllegalArgumentException("Scores are equal, winnerTeamId must be specified");
            }
        }

        Team winner = teamRepository.findById(winnerTeamId)
                .orElseThrow(() -> new EntityNotFoundException("Winner team not found"));
        if (!winner.equals(match.getFirstTeam()) && !winner.equals(match.getSecondTeam())) {
            throw new IllegalArgumentException("Winner team is not a participant of this match");
        }

        match.setScore1(score1);
        match.setScore2(score2);
        match.setWinnerTeam(winner);
        matchRepository.save(match);

        if (match.getNextMatch() != null) {
            Match nextMatch = match.getNextMatch();
            if (nextMatch.getFirstTeam() == null) {
                nextMatch.setFirstTeam(winner);
            } else if (nextMatch.getSecondTeam() == null) {
                nextMatch.setSecondTeam(winner);
            }
            matchRepository.save(nextMatch);
        }

        List<Match> allMatches = matchRepository.findByCompetitionIdOrderByRoundAsc(competitionId);
        boolean allDecided = allMatches.stream().allMatch(m -> m.getWinnerTeam() != null);
        if (allDecided && competition.getStatus() != CompetitionStatus.COMPLETED) {
            competition.setStatus(CompetitionStatus.COMPLETED);
            competitionRepository.save(competition);
            participationService.calculatePlaces(competition);
        }
    }
}