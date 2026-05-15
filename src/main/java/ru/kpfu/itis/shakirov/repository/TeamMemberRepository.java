package ru.kpfu.itis.shakirov.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.kpfu.itis.shakirov.entity.Account;
import ru.kpfu.itis.shakirov.entity.TeamMember;
import ru.kpfu.itis.shakirov.entity.TeamMemberId;

import java.util.List;

public interface TeamMemberRepository extends JpaRepository<TeamMember, TeamMemberId> {

    @Query("SELECT tm.account FROM TeamMember tm WHERE tm.team.id = :teamId")
    List<Account> findAccountsByTeamId(@Param("teamId") Long teamId);

    long countByTeamId(Long teamId);

    boolean existsByTeamIdAndAccountId(Long teamId, Long accountId);
}