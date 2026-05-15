package ru.kpfu.itis.shakirov.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import ru.kpfu.itis.shakirov.dto.CompetitionRequest;
import ru.kpfu.itis.shakirov.dto.CompetitionViewDto;
import ru.kpfu.itis.shakirov.entity.Account;
import ru.kpfu.itis.shakirov.entity.CompetitionStatus;
import ru.kpfu.itis.shakirov.repository.DisciplineRepository;
import ru.kpfu.itis.shakirov.security.AccountUserDetails;
import ru.kpfu.itis.shakirov.service.AccountService;
import ru.kpfu.itis.shakirov.service.CompetitionService;
import ru.kpfu.itis.shakirov.service.MatchService;
import ru.kpfu.itis.shakirov.service.ParticipationService;

import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/competitions")
@RequiredArgsConstructor
public class CompetitionController {
    private final CompetitionService competitionService;
    private final DisciplineRepository disciplineRepo;
    private final ParticipationService participationService;
    private final AccountService accountService;
    private final MatchService matchService;

    @GetMapping
    public String list(@RequestParam(required = false) String discipline,
                       @RequestParam(required = false) String status,
                       @RequestParam(required = false) String city,
                       Model model) {
        model.addAttribute("competitions", competitionService.findDtosByFilters(discipline, status, city));
        model.addAttribute("disciplines", disciplineRepo.findAll());
        model.addAttribute("currentDiscipline", discipline);
        model.addAttribute("currentStatus", status);
        model.addAttribute("currentCity", city);
        return "competition/list";
    }

    @GetMapping("/{id}")
    public String view(@PathVariable Long id, Model model,
                       @AuthenticationPrincipal AccountUserDetails user) {
        CompetitionViewDto viewDto = competitionService.getViewDto(id, user);
        model.addAttribute("comp", viewDto.getCompetition());
        model.addAttribute("userTeams", viewDto.getUserTeams());
        model.addAttribute("participations", viewDto.getParticipations());
        model.addAttribute("matches", viewDto.getMatches());
        model.addAttribute("formattedDatetime", viewDto.getFormattedDatetime());

        boolean isOwner = viewDto.getCompetition().getOwner().getId().equals(user.getId());
        boolean isAdmin = user.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        model.addAttribute("isOwner", isOwner);
        model.addAttribute("isAdmin", isAdmin);

        return "competition/view";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("competition", new CompetitionRequest());
        model.addAttribute("disciplines", disciplineRepo.findAll());
        model.addAttribute("competitionId", null);
        model.addAttribute("formattedDatetime", null);
        return "competition/form";
    }

    @PostMapping("/new")
    public String create(@Valid @ModelAttribute("competition") CompetitionRequest req,
                         BindingResult result,
                         @AuthenticationPrincipal AccountUserDetails user,
                         Model model) {
        result.getFieldErrors().stream()
                .filter(e -> e.getCodes() != null && Arrays.asList(e.getCodes()).contains("Future"))
                .forEach(e -> {
                    if (!"datetime".equals(e.getField())) {
                        result.addError(new org.springframework.validation.FieldError(
                                "competition", "datetime", e.getDefaultMessage()));
                    }
                });

        if (result.hasErrors()) {
            prepareErrorModel(model, result, req, null);
            return "competition/form";
        }
        Account owner = accountService.getAccountFromUserDetails(user);
        try {
            competitionService.create(req, owner);
        } catch (IllegalArgumentException | IllegalStateException e) {
            model.addAttribute("error", e.getMessage());
            prepareErrorModel(model, result, req, null);
            return "competition/form";
        }
        return "redirect:/competitions";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        CompetitionRequest req = competitionService.getCompetitionRequestForEdit(id);
        model.addAttribute("competition", req);
        model.addAttribute("disciplines", disciplineRepo.findAll());
        model.addAttribute("competitionId", id);
        model.addAttribute("formattedDatetime",
                req.getDatetime() != null ? req.getDatetime().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) : null);
        return "competition/form";
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable Long id,
                         @Valid @ModelAttribute("competition") CompetitionRequest req,
                         BindingResult result,
                         @AuthenticationPrincipal AccountUserDetails user,
                         Model model) {
        result.getFieldErrors().stream()
                .filter(e -> e.getCodes() != null && Arrays.asList(e.getCodes()).contains("Future"))
                .forEach(e -> {
                    if (!"datetime".equals(e.getField())) {
                        result.addError(new org.springframework.validation.FieldError(
                                "competition", "datetime", e.getDefaultMessage()));
                    }
                });

        if (result.hasErrors()) {
            prepareErrorModel(model, result, req, id);
            return "competition/form";
        }
        Account updater = accountService.getAccountFromUserDetails(user);
        try {
            competitionService.update(id, req, updater);
        } catch (IllegalArgumentException | IllegalStateException e) {
            model.addAttribute("error", e.getMessage());
            prepareErrorModel(model, result, req, id);
            return "competition/form";
        }
        return "redirect:/competitions/" + id;
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id,
                         @AuthenticationPrincipal AccountUserDetails user,
                         RedirectAttributes redirectAttributes) {
        Account deleter = accountService.getAccountFromUserDetails(user);
        try {
            competitionService.delete(id, deleter);
        } catch (IllegalStateException | IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/competitions/" + id;
        }
        return "redirect:/competitions";
    }

    @PostMapping("/{id}/register")
    public String registerTeam(@PathVariable Long id,
                               @RequestParam Long teamId,
                               @AuthenticationPrincipal AccountUserDetails user,
                               RedirectAttributes redirectAttributes) {
        Account captain = accountService.getAccountFromUserDetails(user);
        try {
            participationService.registerTeam(id, teamId, captain);
        } catch (IllegalStateException | IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/competitions/" + id;
        }
        return "redirect:/competitions/" + id;
    }

    @PostMapping("/{id}/unregister")
    public String unregisterTeam(@PathVariable Long id,
                                 @RequestParam Long teamId,
                                 @AuthenticationPrincipal AccountUserDetails user,
                                 RedirectAttributes redirectAttributes) {
        Account captain = accountService.getAccountFromUserDetails(user);
        try {
            participationService.unregisterTeam(id, teamId, captain);
        } catch (IllegalStateException | IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/competitions/" + id;
        }
        return "redirect:/competitions/" + id;
    }

    @PostMapping("/{id}/start")
    public String startTournament(@PathVariable Long id,
                                  @AuthenticationPrincipal AccountUserDetails user,
                                  RedirectAttributes redirectAttributes) {
        Account organizer = accountService.getAccountFromUserDetails(user);
        try {
            competitionService.startTournament(id, organizer);
        } catch (IllegalStateException | IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/competitions/" + id;
        }
        return "redirect:/competitions/" + id;
    }

    @PostMapping("/{id}/matches/{matchId}/result")
    public String setMatchResult(@PathVariable Long id,
                                 @PathVariable Long matchId,
                                 @RequestParam Integer score1,
                                 @RequestParam Integer score2,
                                 @RequestParam(required = false) Long winnerTeamId,
                                 @AuthenticationPrincipal AccountUserDetails user,
                                 RedirectAttributes redirectAttributes) {
        Account updater = accountService.getAccountFromUserDetails(user);
        try {
            matchService.setResult(id, matchId, score1, score2, winnerTeamId, updater);
        } catch (IllegalStateException | IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/competitions/" + id;
        }
        return "redirect:/competitions/" + id;
    }

    private void prepareErrorModel(Model model, BindingResult result,
                                   CompetitionRequest req, Long competitionId) {
        model.addAttribute("disciplines", disciplineRepo.findAll());
        model.addAttribute("competitionId", competitionId);
        model.addAttribute("formattedDatetime",
                req.getDatetime() != null ? req.getDatetime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) : null);

        Map<String, String> fieldErrors = result.getFieldErrors().stream()
                .collect(Collectors.toMap(
                        e -> e.getField(),
                        e -> e.getDefaultMessage() != null ? e.getDefaultMessage() : "Некорректное значение",
                        (m1, m2) -> m1));
        if (result.hasGlobalErrors()) {
            String globalMsg = result.getGlobalErrors().stream()
                    .map(e -> e.getDefaultMessage() != null ? e.getDefaultMessage() : "Ошибка в данных")
                    .collect(Collectors.joining(", "));
            fieldErrors.put("global", globalMsg);
        }
        model.addAttribute("errors", fieldErrors);
    }
}