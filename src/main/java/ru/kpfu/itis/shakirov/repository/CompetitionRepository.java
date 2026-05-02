package ru.kpfu.itis.shakirov.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.kpfu.itis.shakirov.entity.Competition;
import ru.kpfu.itis.shakirov.entity.CompetitionStatus;

import java.util.List;

public interface CompetitionRepository extends JpaRepository<Competition, Long> {
    List<Competition> findByStatus(CompetitionStatus status);

    @Query("SELECT c FROM Competition c WHERE (SELECT COUNT(p) FROM Participation p WHERE p.competition.id = c.id) >= :minTeams")
    List<Competition> findCompetitionsWithMinTeams(@Param("minTeams") long minTeams);
}
