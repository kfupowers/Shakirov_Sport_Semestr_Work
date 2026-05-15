package ru.kpfu.itis.shakirov.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.ZonedDateTime;

@Entity
@Table(name = "player_requests", schema = "sport")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlayerRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    private Account author;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "discipline_id", nullable = false)
    private Discipline discipline;

    @Column(length = 1000)
    private String description;

    private String contact;

    @Enumerated(EnumType.STRING)
    private PlayerRequestStatus status = PlayerRequestStatus.OPEN;

    @Column(name = "created_at")
    private ZonedDateTime createdAt;
}