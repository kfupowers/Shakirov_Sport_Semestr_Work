package ru.kpfu.itis.shakirov.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.kpfu.itis.shakirov.service.AccountService;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminApiController {

    private final AccountService accountService;

    @PostMapping("/users/{userId}/roles/organizer")
    public ResponseEntity<String> grantOrganizerRole(@PathVariable Long userId) {
        accountService.addRole(userId, "ORGANIZER");
        return ResponseEntity.ok("Organizer role granted");
    }

    @DeleteMapping("/users/{userId}/roles/organizer")
    public ResponseEntity<String> revokeOrganizerRole(@PathVariable Long userId) {
        accountService.removeRole(userId, "ORGANIZER");
        return ResponseEntity.ok("Organizer role revoked");
    }
}