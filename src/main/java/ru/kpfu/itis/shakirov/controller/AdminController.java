package ru.kpfu.itis.shakirov.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import ru.kpfu.itis.shakirov.service.AccountService;
import ru.kpfu.itis.shakirov.service.CompetitionService;
import ru.kpfu.itis.shakirov.service.PlayerRequestService;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AccountService accountService;
    private final CompetitionService competitionService;
    private final PlayerRequestService playerRequestService;

    @GetMapping
    public String index() {
        return "admin/index";
    }

    @GetMapping("/grant")
    public String showGrantPage() {
        return "admin/grant";
    }

    @PostMapping("/grant")
    public String grantOrganizer(@RequestParam String login, Model model) {
        try {
            accountService.addRoleByLogin(login, "ORGANIZER");
            model.addAttribute("success", "Роль ORGANIZER выдана пользователю " + login);
        } catch (Exception e) {
            model.addAttribute("error", "Ошибка: " + e.getMessage());
        }
        return "admin/grant";
    }

    @GetMapping("/competitions")
    public String competitions(Model model) {
        model.addAttribute("competitions", competitionService.findAll());
        return "admin/competitions";
    }

    @PostMapping("/competitions/{id}/delete")
    public String deleteCompetition(@PathVariable Long id) {
        competitionService.deleteByAdmin(id);
        return "redirect:/admin/competitions";
    }

    @GetMapping("/requests")
    public String requests(Model model) {
        model.addAttribute("requests", playerRequestService.findAll());
        return "admin/requests";
    }

    @PostMapping("/requests/{id}/delete")
    public String deleteRequest(@PathVariable Long id) {
        playerRequestService.deleteByAdmin(id);
        return "redirect:/admin/requests";
    }
}