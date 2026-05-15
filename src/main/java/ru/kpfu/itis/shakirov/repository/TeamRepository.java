package ru.kpfu.itis.shakirov.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.kpfu.itis.shakirov.entity.Team;

import java.util.List;

public interface TeamRepository extends JpaRepository<Team, Long> {
    List<Team> findByCaptainId(Long captainId);
    List<Team> findByCaptainIdAndActiveTrue(Long captainId);
    @Query("SELECT DISTINCT t FROM Team t LEFT JOIN t.members m WHERE t.captain.id = :accountId OR m.account.id = :accountId")
    List<Team> findAllByMemberOrCaptain(@Param("accountId") Long accountId);
}
