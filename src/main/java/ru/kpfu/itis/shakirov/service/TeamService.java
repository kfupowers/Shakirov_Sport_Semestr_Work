package ru.kpfu.itis.shakirov.service;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.hibernate.Hibernate;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.kpfu.itis.shakirov.entity.Account;
import ru.kpfu.itis.shakirov.entity.Team;
import ru.kpfu.itis.shakirov.entity.TeamMember;
import ru.kpfu.itis.shakirov.entity.TeamMemberId;
import ru.kpfu.itis.shakirov.repository.AccountRepository;
import ru.kpfu.itis.shakirov.repository.ParticipationRepository;
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
    private final ParticipationRepository participationRepo;

    @Transactional
    public Team createTeam(String name, boolean active, Account captain) {
        Team team = Team.builder()
                .name(name)
                .captain(captain)
                .active(active)
                .build();
        team = teamRepo.save(team);

        TeamMemberId memberId = new TeamMemberId(team.getId(), captain.getId());
        TeamMember tm = TeamMember.builder()
                .id(memberId)
                .team(team)
                .account(captain)
                .build();
        memberRepo.save(tm);

        log.info("Team '{}' created by captain {}", team.getName(), captain.getLogin());
        return team;
    }

    @Transactional(readOnly = true)
    public Team getById(Long id) {
        Team team = teamRepo.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Team not found"));
        Hibernate.initialize(team.getCaptain());
        return team;
    }

    @Transactional(readOnly = true)
    public List<Team> getTeamsByCaptain(Long captainId) {
        List<Team> teams = teamRepo.findByCaptainId(captainId);
        teams.forEach(team -> Hibernate.initialize(team.getCaptain()));
        return teams;
    }

    @Transactional(readOnly = true)
    public List<Team> getActiveTeamsByCaptain(Long captainId) {
        List<Team> teams = teamRepo.findByCaptainIdAndActiveTrue(captainId);
        teams.forEach(team -> Hibernate.initialize(team.getCaptain()));
        return teams;
    }

    @Transactional(readOnly = true)
    public List<Account> getMembers(Long teamId) {
        return memberRepo.findAccountsByTeamId(teamId);
    }

    @Transactional
    public void addMember(Long teamId, String login, Account captain) {
        Team team = getById(teamId);
        if (!team.getCaptain().getId().equals(captain.getId())) {
            throw new AccessDeniedException("Only team captain can add members");
        }

        checkTeamHasNoParticipation(teamId);

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

        checkTeamHasNoParticipation(teamId);

        TeamMemberId id = new TeamMemberId(teamId, accountId);
        if (memberRepo.existsById(id)) {
            memberRepo.deleteById(id);
            log.info("Captain {} removed member {} from team {}", captain.getLogin(), accountId, team.getName());
        } else {
            throw new EntityNotFoundException("Member not found in team");
        }
    }

    @Transactional
    public void updateTeam(Long teamId, String name, boolean active, Account currentUser) {
        Team team = getById(teamId);
        if (!team.getCaptain().getId().equals(currentUser.getId())) {
            throw new AccessDeniedException("Only captain can edit the team");
        }
        team.setName(name);
        team.setActive(active);
        teamRepo.save(team);
    }

    @Transactional
    public void setActive(Long teamId, boolean active, Account currentUser) {
        Team team = getById(teamId);
        if (!team.getCaptain().getId().equals(currentUser.getId())) {
            throw new AccessDeniedException("Only captain can change team activity");
        }
        team.setActive(active);
        teamRepo.save(team);
    }

    @Transactional(readOnly = true)
    public List<Team> getMyTeams(Long accountId) {
        List<Team> teams = teamRepo.findAllByMemberOrCaptain(accountId);
        teams.forEach(team -> Hibernate.initialize(team.getCaptain()));
        return teams;
    }

    private void checkTeamHasNoParticipation(Long teamId) {
        boolean hasParticipation = !participationRepo.findByTeamId(teamId).isEmpty();
        if (hasParticipation) {
            throw new IllegalStateException("Cannot modify team members because the team has participated in competitions");
        }
    }
}