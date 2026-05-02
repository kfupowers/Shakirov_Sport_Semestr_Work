package ru.kpfu.itis.shakirov.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.kpfu.itis.shakirov.entity.Participation;

import java.util.List;

public interface ParticipationRepository extends JpaRepository<Participation, Long> {
    boolean existsByTeamIdAndCompetitionId(Long teamId, Long competitionId);
    List<Participation> findByCompetitionId(Long competitionId);
}
