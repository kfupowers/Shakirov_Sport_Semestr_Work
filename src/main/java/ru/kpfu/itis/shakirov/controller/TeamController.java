package ru.kpfu.itis.shakirov.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import ru.kpfu.itis.shakirov.entity.Account;
import ru.kpfu.itis.shakirov.entity.Team;
import ru.kpfu.itis.shakirov.repository.ParticipationRepository;
import ru.kpfu.itis.shakirov.security.AccountUserDetails;
import ru.kpfu.itis.shakirov.service.AccountService;
import ru.kpfu.itis.shakirov.service.TeamService;

import java.util.List;

@Controller
@RequestMapping("/teams")
@RequiredArgsConstructor
public class TeamController {

    private final TeamService teamService;
    private final AccountService accountService;
    private final ParticipationRepository participationRepo;

    @GetMapping("/list")
    public String redirectList() {
        return "redirect:/teams";
    }

    @GetMapping
    public String list(@AuthenticationPrincipal AccountUserDetails user, Model model) {
        Account account = accountService.getAccountFromUserDetails(user);
        model.addAttribute("teams", teamService.getMyTeams(account.getId()));
        model.addAttribute("currentUserId", account.getId());
        return "teams/list";
    }

    @GetMapping("/new")
    public String createForm() {
        return "teams/form";
    }

    @PostMapping("/new")
    public String create(@RequestParam String name,
                         @RequestParam(defaultValue = "false") boolean active,
                         @AuthenticationPrincipal AccountUserDetails user) {
        Account captain = accountService.getAccountFromUserDetails(user);
        teamService.createTeam(name, active, captain);
        return "redirect:/teams";
    }

    @GetMapping("/{id}")
    public String view(@PathVariable Long id,
                       @AuthenticationPrincipal AccountUserDetails user,
                       Model model) {
        Team team = teamService.getById(id);
        List<Account> members = teamService.getMembers(id);
        boolean canModifyMembers = team.getCaptain().getId().equals(user.getId())
                && participationRepo.findByTeamId(id).isEmpty();
        model.addAttribute("team", team);
        model.addAttribute("members", members);
        model.addAttribute("user", user);
        model.addAttribute("canModifyMembers", canModifyMembers);
        return "teams/view";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id,
                           @AuthenticationPrincipal AccountUserDetails user,
                           Model model) {
        Team team = teamService.getById(id);
        if (!team.getCaptain().getId().equals(user.getId())) {
            throw new org.springframework.security.access.AccessDeniedException("Только капитан может редактировать команду");
        }
        model.addAttribute("team", team);
        model.addAttribute("teamId", id);
        return "teams/form";
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable Long id,
                         @RequestParam String name,
                         @RequestParam(defaultValue = "false") boolean active,
                         @AuthenticationPrincipal AccountUserDetails user) {
        Account updater = accountService.getAccountFromUserDetails(user);
        teamService.updateTeam(id, name, active, updater);
        return "redirect:/teams/" + id;
    }

    @PostMapping("/{id}/activate")
    public String activate(@PathVariable Long id,
                           @AuthenticationPrincipal AccountUserDetails user) {
        Account account = accountService.getAccountFromUserDetails(user);
        teamService.setActive(id, true, account);
        return "redirect:/teams/" + id;
    }

    @PostMapping("/{id}/deactivate")
    public String deactivate(@PathVariable Long id,
                             @AuthenticationPrincipal AccountUserDetails user) {
        Account account = accountService.getAccountFromUserDetails(user);
        teamService.setActive(id, false, account);
        return "redirect:/teams/" + id;
    }
}