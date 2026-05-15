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
import ru.kpfu.itis.shakirov.security.AccountUserDetails;
import ru.kpfu.itis.shakirov.service.AccountService;
import ru.kpfu.itis.shakirov.service.CompetitionService;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class CompetitionApiController implements CompetitionApi {

    private final CompetitionService competitionService;
    private final AccountService accountService;

    @Override
    public ResponseEntity<List<CompetitionResponse>> getAllCompetitions(
            @RequestParam(required = false) String discipline,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String city) {
        List<CompetitionResponse> responses = competitionService.findResponsesByFilters(discipline, status, city);
        return ResponseEntity.ok(responses);
    }

    @Override
    public ResponseEntity<CompetitionResponse> getCompetitionById(Long id) {
        CompetitionResponse response = competitionService.getResponseById(id);
        return ResponseEntity.ok(response);
    }

    @Override
    public ResponseEntity<CompetitionResponse> createCompetition(CreateCompetitionRequest request) {
        Account owner = getCurrentUser();
        CompetitionRequest compReq = toCompetitionRequest(request);
        CompetitionResponse response = competitionService.createResponse(compReq, owner);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @Override
    public ResponseEntity<CompetitionResponse> updateCompetition(Long id, UpdateCompetitionRequest request) {
        Account updater = getCurrentUser();
        CompetitionRequest compReq = toCompetitionRequest(request);
        CompetitionResponse response = competitionService.updateResponse(id, compReq, updater);
        return ResponseEntity.ok(response);
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

    private CompetitionRequest toCompetitionRequest(CreateCompetitionRequest request) {
        CompetitionRequest req = new CompetitionRequest();
        req.setTitle(request.getTitle());
        if (request.getDatetime() != null) {
            req.setDatetime(request.getDatetime().toLocalDateTime());
        }
        req.setAddress(request.getAddress());
        req.setDisciplineId(request.getDisciplineId());
        req.setTournamentSize(request.getTournamentSize());
        req.setRequiredTeamSize(request.getRequiredTeamSize());
        return req;
    }

    private CompetitionRequest toCompetitionRequest(UpdateCompetitionRequest request) {
        CompetitionRequest req = new CompetitionRequest();
        req.setTitle(request.getTitle());
        if (request.getDatetime() != null) {
            req.setDatetime(request.getDatetime().toLocalDateTime());
        }
        req.setAddress(request.getAddress());
        req.setDisciplineId(request.getDisciplineId());
        req.setTournamentSize(request.getTournamentSize());
        req.setRequiredTeamSize(request.getRequiredTeamSize());
        return req;
    }
}