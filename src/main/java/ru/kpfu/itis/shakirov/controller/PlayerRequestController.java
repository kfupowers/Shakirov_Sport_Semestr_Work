package ru.kpfu.itis.shakirov.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import ru.kpfu.itis.shakirov.entity.Account;
import ru.kpfu.itis.shakirov.exception.EntityNotFoundException;
import ru.kpfu.itis.shakirov.repository.DisciplineRepository;
import ru.kpfu.itis.shakirov.security.AccountUserDetails;
import ru.kpfu.itis.shakirov.service.AccountService;
import ru.kpfu.itis.shakirov.service.PlayerRequestService;

@Controller
@RequestMapping("/players")
@RequiredArgsConstructor
public class PlayerRequestController {

    private final PlayerRequestService playerRequestService;
    private final DisciplineRepository disciplineRepo;
    private final AccountService accountService;

    @GetMapping("/search")
    public String search(@RequestParam(required = false) String discipline,
                         Model model,
                         @AuthenticationPrincipal AccountUserDetails user) {
        Account currentUser = user != null ? accountService.getAccountFromUserDetails(user) : null;
        model.addAttribute("requests",
                discipline != null && !discipline.isBlank() ?
                        playerRequestService.findByDiscipline(discipline) :
                        playerRequestService.findOpen());
        model.addAttribute("disciplines", disciplineRepo.findAll());
        model.addAttribute("currentDiscipline", discipline);
        model.addAttribute("isAdmin", user != null && user.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN")));
        model.addAttribute("currentUserId", currentUser != null ? currentUser.getId() : null);
        return "players/search";
    }

    @GetMapping("/my-requests")
    public String myRequests(@AuthenticationPrincipal AccountUserDetails user, Model model) {
        Account account = accountService.getAccountFromUserDetails(user);
        model.addAttribute("requests", playerRequestService.findMyRequests(account));
        return "players/my-requests";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("disciplines", disciplineRepo.findAll());
        return "players/form";
    }

    @PostMapping("/new")
    public String create(@RequestParam Long disciplineId,
                         @RequestParam(required = false) String description,
                         @RequestParam(required = false) String contact,
                         @AuthenticationPrincipal AccountUserDetails user,
                         Model model) {
        try {
            Account author = accountService.getAccountFromUserDetails(user);
            playerRequestService.create(author, disciplineId, description, contact);
        } catch (EntityNotFoundException | IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("disciplines", disciplineRepo.findAll());
            return "players/form";
        }
        return "redirect:/players/my-requests";
    }

    @PostMapping("/{id}/close")
    public String close(@PathVariable Long id,
                        @AuthenticationPrincipal AccountUserDetails user) {
        Account account = accountService.getAccountFromUserDetails(user);
        playerRequestService.close(id, account);
        return "redirect:/players/my-requests";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id,
                         @AuthenticationPrincipal AccountUserDetails user) {
        Account account = accountService.getAccountFromUserDetails(user);
        playerRequestService.delete(id, account);
        return "redirect:/players/search";
    }
}