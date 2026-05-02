package ru.kpfu.itis.shakirov.service;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.kpfu.itis.shakirov.entity.Account;
import ru.kpfu.itis.shakirov.entity.Team;
import ru.kpfu.itis.shakirov.entity.TeamMember;
import ru.kpfu.itis.shakirov.entity.TeamMemberId;
import ru.kpfu.itis.shakirov.repository.AccountRepository;
import ru.kpfu.itis.shakirov.repository.TeamMemberRepository;
import ru.kpfu.itis.shakirov.repository.TeamRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class TeamService {
    private final TeamRepository teamRepo;
    private final TeamMemberRepository memberRepo;
    private final AccountRepository accountRepo;

    @Transactional
    public Team createTeam(String name, Account captain) {
        Team team = Team.builder()
                .name(name)
                .captain(captain)
                .active(true)
                .build();
        return teamRepo.save(team);
    }

    @Transactional(readOnly = true)
    public Team getById(Long id) {
        return teamRepo.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Team not found"));
    }

    @Transactional(readOnly = true)
    public List<Team> getTeamsByCaptain(Long captainId) {
        return teamRepo.findByCaptainId(captainId);
    }

    @Transactional
    public void addMember(Long teamId, String login, Account captain) {
        Team team = getById(teamId);
        if (!team.getCaptain().getId().equals(captain.getId())) {
            throw new AccessDeniedException("Only team captain can add members");
        }

        Account member = accountRepo.findByLogin(login)
                .orElseThrow(() -> new EntityNotFoundException("User not found with login: " + login));

        TeamMemberId id = new TeamMemberId(teamId, member.getId());
        if (!memberRepo.existsById(id)) {
            TeamMember tm = TeamMember.builder()
                    .id(id)
                    .team(team)
                    .account(member)
                    .build();
            memberRepo.save(tm);
            log.info("Captain {} added member {} to team {}", captain.getLogin(), member.getLogin(), team.getName());
        } else {
            throw new IllegalStateException("User is already a member of this team");
        }
    }

    @Transactional
    public void removeMember(Long teamId, Long accountId, Account captain) {
        Team team = getById(teamId);
        if (!team.getCaptain().getId().equals(captain.getId())) {
            throw new AccessDeniedException("Only team captain can remove members");
        }

        if (captain.getId().equals(accountId)) {
            throw new IllegalArgumentException("Captain cannot remove himself from the team");
        }

        TeamMemberId id = new TeamMemberId(teamId, accountId);
        if (memberRepo.existsById(id)) {
            memberRepo.deleteById(id);
            log.info("Captain {} removed member {} from team {}", captain.getLogin(), accountId, team.getName());
        } else {
            throw new EntityNotFoundException("Member not found in team");
        }
    }
}