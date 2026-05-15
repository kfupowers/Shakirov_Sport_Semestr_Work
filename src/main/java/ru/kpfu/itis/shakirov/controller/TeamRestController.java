package ru.kpfu.itis.shakirov.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import ru.kpfu.itis.shakirov.entity.Account;
import ru.kpfu.itis.shakirov.security.AccountUserDetails;
import ru.kpfu.itis.shakirov.service.AccountService;
import ru.kpfu.itis.shakirov.service.TeamService;

import java.util.List;

@RestController
@RequestMapping("/api/teams/{teamId}/members")
@RequiredArgsConstructor
public class TeamRestController {

    private final TeamService teamService;
    private final AccountService accountService;

    @GetMapping
    public ResponseEntity<List<Account>> getMembers(@PathVariable Long teamId) {
        List<Account> members = teamService.getMembers(teamId);
        return ResponseEntity.ok(members);
    }

    @PostMapping
    public ResponseEntity<String> addMember(@PathVariable Long teamId,
                                            @RequestParam String login,
                                            @AuthenticationPrincipal AccountUserDetails currentUser) {
        Account captain = accountService.getAccountFromUserDetails(currentUser);
        teamService.addMember(teamId, login, captain);
        return ResponseEntity.ok("Участник добавлен");
    }

    @DeleteMapping("/{accountId}")
    public ResponseEntity<Void> removeMember(@PathVariable Long teamId,
                                             @PathVariable Long accountId,
                                             @AuthenticationPrincipal AccountUserDetails currentUser) {
        Account captain = accountService.getAccountFromUserDetails(currentUser);
        teamService.removeMember(teamId, accountId, captain);
        return ResponseEntity.noContent().build();
    }
}