package ru.kpfu.itis.shakirov.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.kpfu.itis.shakirov.entity.Participation;

import java.util.List;
import java.util.Optional;

public interface ParticipationRepository extends JpaRepository<Participation, Long> {
    List<Participation> findByCompetitionId(Long competitionId);
    boolean existsByTeamIdAndCompetitionId(Long teamId, Long competitionId);
    Optional<Participation> findByCompetitionIdAndTeamId(Long competitionId, Long teamId);
    List<Participation> findByTeamId(Long teamId);
    @Query("SELECT DISTINCT p FROM Participation p JOIN p.team.members tm WHERE tm.account.id = :accountId")
    List<Participation> findByMemberAccountId(@Param("accountId") Long accountId);
    long countByCompetitionId(Long competitionId);
}