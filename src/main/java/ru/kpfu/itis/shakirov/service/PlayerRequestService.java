package ru.kpfu.itis.shakirov.service;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.hibernate.Hibernate;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.kpfu.itis.shakirov.entity.*;
import ru.kpfu.itis.shakirov.repository.DisciplineRepository;
import ru.kpfu.itis.shakirov.repository.PlayerRequestRepository;

import java.time.ZonedDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PlayerRequestService {
    private final PlayerRequestRepository repository;
    private final DisciplineRepository disciplineRepo;

    @Transactional
    public PlayerRequest create(Account author, Long disciplineId, String description, String contact) {
        Discipline discipline = disciplineRepo.findById(disciplineId)
                .orElseThrow(() -> new EntityNotFoundException("Discipline not found"));
        PlayerRequest request = PlayerRequest.builder()
                .author(author)
                .discipline(discipline)
                .description(description)
                .contact(contact)
                .status(PlayerRequestStatus.OPEN)
                .createdAt(ZonedDateTime.now())
                .build();
        return repository.save(request);
    }

    @Transactional
    public void close(Long requestId, Account user) {
        PlayerRequest request = repository.findById(requestId)
                .orElseThrow(() -> new EntityNotFoundException("Request not found"));
        if (!request.getAuthor().getId().equals(user.getId())) {
            throw new AccessDeniedException("Only the author can close the request");
        }
        request.setStatus(PlayerRequestStatus.CLOSED);
        repository.save(request);
    }

    @Transactional(readOnly = true)
    public List<PlayerRequest> findOpen() {
        List<PlayerRequest> requests = repository.findByStatusOrderByCreatedAtDesc(PlayerRequestStatus.OPEN);
        requests.forEach(req -> {
            Hibernate.initialize(req.getAuthor());
            Hibernate.initialize(req.getDiscipline());
        });
        return requests;
    }

    @Transactional(readOnly = true)
    public List<PlayerRequest> findByDiscipline(String disciplineName) {
        List<PlayerRequest> requests = repository.findByDisciplineNameAndStatusOrderByCreatedAtDesc(
                disciplineName, PlayerRequestStatus.OPEN);
        requests.forEach(req -> {
            Hibernate.initialize(req.getAuthor());
            Hibernate.initialize(req.getDiscipline());
        });
        return requests;
    }

    @Transactional(readOnly = true)
    public List<PlayerRequest> findMyRequests(Account user) {
        List<PlayerRequest> requests = repository.findByAuthorId(user.getId());
        requests.forEach(req -> {
            Hibernate.initialize(req.getDiscipline());
        });
        return requests;
    }

    @Transactional(readOnly = true)
    public List<PlayerRequest> findAll() {
        List<PlayerRequest> requests = repository.findAll();
        requests.forEach(req -> {
            Hibernate.initialize(req.getAuthor());
            Hibernate.initialize(req.getDiscipline());
        });
        return requests;
    }

    @Transactional
    public void delete(Long requestId, Account user) {
        PlayerRequest request = repository.findById(requestId)
                .orElseThrow(() -> new EntityNotFoundException("Request not found"));
        boolean isAdmin = user.getRoles().stream()
                .anyMatch(role -> role.getName().equals("ADMIN"));
        if (!request.getAuthor().getId().equals(user.getId()) && !isAdmin) {
            throw new AccessDeniedException("Only author or admin can delete a request");
        }
        repository.delete(request);
    }

    @Transactional
    public void deleteByAdmin(Long requestId) {
        repository.deleteById(requestId);
    }
}