package ru.kpfu.itis.shakirov.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import ru.kpfu.itis.shakirov.dto.CompetitionDto;
import ru.kpfu.itis.shakirov.dto.CompetitionRequest;
import ru.kpfu.itis.shakirov.entity.*;
import ru.kpfu.itis.shakirov.repository.DisciplineRepository;
import ru.kpfu.itis.shakirov.security.AccountUserDetails;
import ru.kpfu.itis.shakirov.service.AccountService;
import ru.kpfu.itis.shakirov.service.CompetitionService;
import ru.kpfu.itis.shakirov.service.MatchService;
import ru.kpfu.itis.shakirov.service.ParticipationService;
import ru.kpfu.itis.shakirov.service.TeamService;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/competitions")
@RequiredArgsConstructor
public class CompetitionController {
    private final CompetitionService competitionService;
    private final DisciplineRepository disciplineRepo;
    private final TeamService teamService;
    private final ParticipationService participationService;
    private final MatchService matchService;
    private final AccountService accountService;

    @GetMapping
    public String list(@RequestParam(required = false) String discipline,
                       @RequestParam(required = false) CompetitionStatus status,
                       Model model) {
        List<Competition> comps = competitionService.findByFilters(discipline, status);

        List<CompetitionDto> dtoList = comps.stream()
                .map(this::toDto)
                .collect(Collectors.toList());

        model.addAttribute("competitions", dtoList);
        model.addAttribute("disciplines", disciplineRepo.findAll());
        model.addAttribute("currentDiscipline", discipline);
        model.addAttribute("currentStatus", status != null ? status.name() : null);
        return "competition/list";
    }

    @GetMapping("/{id}")
    public String view(@PathVariable Long id, Model model,
                       @AuthenticationPrincipal AccountUserDetails user) {
        Competition comp = competitionService.getById(id);
        List<Team> userTeams = teamService.getTeamsByCaptain(user.getId());
        List<Participation> participations = participationService.findByCompetitionId(id);
        List<Match> matches = matchService.findByCompetitionIdOrderByRoundAsc(id);
        model.addAttribute("comp", comp);
        model.addAttribute("userTeams", userTeams);
        model.addAttribute("participations", participations);
        model.addAttribute("matches", matches);
        model.addAttribute("formattedDatetime",
                comp.getDatetime().format(DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm")));
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
        String datetimeStr = (String) result.getFieldValue("datetime");

        if (result.hasErrors()) {
            prepareErrorModel(model, result, req, null, datetimeStr);
            return "competition/form";
        }
        Account owner = accountService.getAccountFromUserDetails(user);
        competitionService.create(req, owner);
        return "redirect:/competitions";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        Competition comp = competitionService.getById(id);
        CompetitionRequest req = new CompetitionRequest();
        req.setTitle(comp.getTitle());
        req.setDatetime(comp.getDatetime().toLocalDateTime());
        req.setAddress(comp.getAddress());
        req.setDisciplineId(comp.getDiscipline().getId());
        model.addAttribute("competition", req);
        model.addAttribute("disciplines", disciplineRepo.findAll());
        model.addAttribute("competitionId", id);
        model.addAttribute("formattedDatetime",
                comp.getDatetime().toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        return "competition/form";
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable Long id,
                         @Valid @ModelAttribute("competition") CompetitionRequest req,
                         BindingResult result,
                         @AuthenticationPrincipal AccountUserDetails user,
                         Model model) {
        String datetimeStr = (String) result.getFieldValue("datetime");
        if (result.hasErrors()) {
            prepareErrorModel(model, result, req, id, datetimeStr);
            return "competition/form";
        }
        Account updater = accountService.getAccountFromUserDetails(user);
        ZonedDateTime zoned = req.getDatetime().atZone(ZoneId.systemDefault());
        competitionService.update(id, req, updater);
        return "redirect:/competitions/" + id;
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id,
                         @AuthenticationPrincipal AccountUserDetails user) {
        Account deleter = accountService.getAccountFromUserDetails(user);
        competitionService.delete(id, deleter);
        return "redirect:/competitions";
    }

    @PostMapping("/{id}/register")
    public String registerTeam(@PathVariable Long id,
                               @RequestParam Long teamId,
                               @AuthenticationPrincipal AccountUserDetails user) {
        Account captain = accountService.getAccountFromUserDetails(user);
        participationService.registerTeam(id, teamId, captain);
        return "redirect:/competitions/" + id;
    }

    private void prepareErrorModel(Model model, BindingResult result,
                                   CompetitionRequest req, Long competitionId,
                                   String datetimeStr) {
        model.addAttribute("disciplines", disciplineRepo.findAll());
        model.addAttribute("competitionId", competitionId);
        model.addAttribute("formattedDatetime",
                (datetimeStr != null && !datetimeStr.isBlank()) ? datetimeStr : null);

        Map<String, String> fieldErrors = result.getFieldErrors().stream()
                .collect(Collectors.toMap(
                        org.springframework.validation.FieldError::getField,
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

    private CompetitionDto toDto(Competition c) {
        return CompetitionDto.builder()
                .id(c.getId())
                .title(c.getTitle())
                .address(c.getAddress())
                .disciplineName(c.getDiscipline().getName())
                .ownerLogin(c.getOwner().getLogin())
                .status(c.getStatus().name())
                .participantCount(c.getParticipations().size())
                .formattedDatetime(c.getDatetime().format(DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm")))
                .build();
    }
}