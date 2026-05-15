package ru.kpfu.itis.shakirov.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.kpfu.itis.shakirov.entity.Match;

import java.util.List;

public interface MatchRepository extends JpaRepository<Match, Long> {
    List<Match> findByCompetitionIdOrderByRoundAsc(Long competitionId);
    void deleteByCompetitionId(Long competitionId);
}