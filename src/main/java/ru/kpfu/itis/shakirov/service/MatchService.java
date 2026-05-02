package ru.kpfu.itis.shakirov.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.kpfu.itis.shakirov.entity.Match;
import ru.kpfu.itis.shakirov.repository.MatchRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MatchService {

    private final MatchRepository matchRepository;

    @Transactional(readOnly = true)
    public List<Match> findByCompetitionIdOrderByRoundAsc(Long competitionId) {
        return matchRepository.findByCompetitionIdOrderByRoundAsc(competitionId);
    }
}