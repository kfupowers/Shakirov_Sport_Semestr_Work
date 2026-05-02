package ru.kpfu.itis.shakirov.service;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.kpfu.itis.shakirov.dto.CompetitionRequest;
import ru.kpfu.itis.shakirov.entity.Account;
import ru.kpfu.itis.shakirov.entity.Competition;
import ru.kpfu.itis.shakirov.entity.CompetitionStatus;
import ru.kpfu.itis.shakirov.entity.Discipline;
import ru.kpfu.itis.shakirov.entity.Role;
import ru.kpfu.itis.shakirov.repository.CompetitionCriteriaRepository;
import ru.kpfu.itis.shakirov.repository.CompetitionRepository;
import ru.kpfu.itis.shakirov.repository.DisciplineRepository;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class CompetitionService {
    private final CompetitionRepository competitionRepo;
    private final CompetitionCriteriaRepository criteriaRepo;
    private final DisciplineRepository disciplineRepo;

    @Cacheable(value = "competitions", key = "#disciplineName == null ? 'all' : #disciplineName")
    @Transactional(readOnly = true)
    public List<Competition> findByFilters(String disciplineName, CompetitionStatus status) {
        return criteriaRepo.findByFilters(disciplineName, status);
    }

    @Cacheable(value = "competition", key = "#id")
    @Transactional(readOnly = true)
    public Competition getById(Long id) {
        return competitionRepo.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Competition not found"));
    }

    @Transactional
    @CacheEvict(value = {"competitions", "competition"}, allEntries = true)
    public Competition create(CompetitionRequest request, Account owner) {
        Discipline discipline = disciplineRepo.findById(request.getDisciplineId())
                .orElseThrow(() -> new EntityNotFoundException("Discipline not found"));

        ZonedDateTime zonedDatetime = request.getDatetime().atZone(ZoneId.systemDefault());

        Competition comp = Competition.builder()
                .title(request.getTitle())
                .datetime(zonedDatetime)
                .address(request.getAddress())
                .discipline(discipline)
                .owner(owner)
                .status(CompetitionStatus.OPEN)
                .build();
        competitionRepo.save(comp);
        log.info("Competition '{}' created by {}", comp.getTitle(), owner.getLogin());
        return comp;
    }

    @Transactional
    @CacheEvict(value = {"competitions", "competition"}, allEntries = true)
    public Competition update(Long id, CompetitionRequest request, Account currentUser) {
        Competition comp = getById(id);
        if (!comp.getOwner().getId().equals(currentUser.getId()) &&
                currentUser.getRoles().stream().noneMatch(role -> role.getName().equals("ADMIN"))) {
            throw new AccessDeniedException("You are not allowed to edit this competition");
        }
        Discipline discipline = disciplineRepo.findById(request.getDisciplineId())
                .orElseThrow(() -> new EntityNotFoundException("Discipline not found"));
        comp.setTitle(request.getTitle());
        comp.setDatetime(request.getDatetime().atZone(ZoneId.systemDefault()));
        comp.setAddress(request.getAddress());
        comp.setDiscipline(discipline);
        return competitionRepo.save(comp);
    }

    @Transactional
    @CacheEvict(value = {"competitions", "competition"}, allEntries = true)
    public void delete(Long id, Account currentUser) {
        Competition comp = getById(id);
        if (!comp.getOwner().getId().equals(currentUser.getId()) &&
                currentUser.getRoles().stream().noneMatch(role -> role.getName().equals("ADMIN"))) {
            throw new AccessDeniedException("You are not allowed to delete this competition");
        }
        competitionRepo.deleteById(id);
        log.info("Competition {} deleted by {}", id, currentUser.getLogin());
    }
}