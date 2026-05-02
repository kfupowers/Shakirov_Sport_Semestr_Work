package ru.kpfu.itis.shakirov.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import ru.kpfu.itis.shakirov.api.generated.api.CompetitionApi;
import ru.kpfu.itis.shakirov.api.generated.dto.*;
import ru.kpfu.itis.shakirov.dto.CompetitionRequest;
import ru.kpfu.itis.shakirov.entity.Account;
import ru.kpfu.itis.shakirov.entity.Competition;
import ru.kpfu.itis.shakirov.entity.CompetitionStatus;
import ru.kpfu.itis.shakirov.security.AccountUserDetails;
import ru.kpfu.itis.shakirov.service.AccountService;
import ru.kpfu.itis.shakirov.service.CompetitionService;

import java.time.OffsetDateTime;
import java.util.List;

@RestController
@RequiredArgsConstructor
public class CompetitionApiController implements CompetitionApi {

    private final CompetitionService competitionService;
    private final AccountService accountService;

    @Override
    public ResponseEntity<List<CompetitionResponse>> getAllCompetitions(
            @RequestParam(required = false) String discipline,
            @RequestParam(required = false) String status) {
        CompetitionStatus competitionStatus = status != null
                ? CompetitionStatus.valueOf(status.toUpperCase()) : null;
        List<Competition> comps = competitionService.findByFilters(discipline, competitionStatus);
        List<CompetitionResponse> response = comps.stream()
                .map(this::toResponse)
                .toList();
        return ResponseEntity.ok(response);
    }

    @Override
    public ResponseEntity<CompetitionResponse> getCompetitionById(Long id) {
        Competition c = competitionService.getById(id);
        return ResponseEntity.ok(toResponse(c));
    }

    @Override
    public ResponseEntity<CompetitionResponse> createCompetition(CreateCompetitionRequest request) {
        Account owner = getCurrentUser();
        CompetitionRequest compReq = new CompetitionRequest();
        compReq.setTitle(request.getTitle());
        if (request.getDatetime() != null) {
            compReq.setDatetime(request.getDatetime().toLocalDateTime());
        }
        compReq.setAddress(request.getAddress());
        compReq.setDisciplineId(request.getDisciplineId());

        Competition created = competitionService.create(compReq, owner);
        return ResponseEntity.status(HttpStatus.CREATED).body(toResponse(created));
    }

    @Override
    public ResponseEntity<CompetitionResponse> updateCompetition(Long id, UpdateCompetitionRequest request) {
        Account updater = getCurrentUser();
        CompetitionRequest compReq = new CompetitionRequest();
        compReq.setTitle(request.getTitle());
        if (request.getDatetime() != null) {
            compReq.setDatetime(request.getDatetime().toLocalDateTime());
        }
        compReq.setAddress(request.getAddress());
        compReq.setDisciplineId(request.getDisciplineId());

        Competition updated = competitionService.update(id, compReq, updater);
        return ResponseEntity.ok(toResponse(updated));
    }

    @Override
    public ResponseEntity<Void> deleteCompetition(Long id) {
        Account deleter = getCurrentUser();
        competitionService.delete(id, deleter);
        return ResponseEntity.noContent().build();
    }

    private Account getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof AccountUserDetails userDetails) {
            return accountService.getAccountFromUserDetails(userDetails);
        }
        throw new IllegalStateException("User not authenticated");
    }

    private CompetitionResponse toResponse(Competition c) {
        CompetitionResponse response = new CompetitionResponse(
                c.getId(),
                c.getTitle(),
                c.getDiscipline().getName(),
                c.getOwner().getLogin(),
                CompetitionResponse.StatusEnum.fromValue(c.getStatus().name())
        );
        
        response.setAddress(c.getAddress());
        if (c.getDatetime() != null) {
            response.setDatetime(c.getDatetime().toOffsetDateTime());
        }
        response.setParticipantCount(c.getParticipations().size());

        return response;
    }
}