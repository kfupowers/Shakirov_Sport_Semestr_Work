package ru.kpfu.itis.shakirov.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import ru.kpfu.itis.shakirov.entity.Account;
import ru.kpfu.itis.shakirov.security.AccountUserDetails;
import ru.kpfu.itis.shakirov.service.AccountService;
import ru.kpfu.itis.shakirov.service.ParticipationService;
import ru.kpfu.itis.shakirov.entity.Participation;

import java.util.List;

@Controller
@RequestMapping("/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final AccountService accountService;
    private final ParticipationService participationService;

    @GetMapping
    public String viewProfile(@AuthenticationPrincipal AccountUserDetails user, Model model) {
        Account account = accountService.getAccountFromUserDetails(user);
        List<Participation> participations = participationService.findByAccountId(account.getId());
        model.addAttribute("participations", participations);
        model.addAttribute("account", account);
        return "profile";
    }
}