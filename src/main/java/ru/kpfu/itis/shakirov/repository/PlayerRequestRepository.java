package ru.kpfu.itis.shakirov.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.kpfu.itis.shakirov.entity.PlayerRequest;
import ru.kpfu.itis.shakirov.entity.PlayerRequestStatus;

import java.util.List;

public interface PlayerRequestRepository extends JpaRepository<PlayerRequest, Long> {
    List<PlayerRequest> findByStatusOrderByCreatedAtDesc(PlayerRequestStatus status);
    List<PlayerRequest> findByDisciplineNameAndStatusOrderByCreatedAtDesc(String disciplineName, PlayerRequestStatus status);
    List<PlayerRequest> findByAuthorId(Long authorId);
}