package ru.kpfu.itis.shakirov.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "competitions", schema = "sport")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Competition {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    private String title;

    @NotNull
    private ZonedDateTime datetime;

    private String address;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "discipline_id")
    private Discipline discipline;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id")
    private Account owner;

    @Enumerated(EnumType.STRING)
    private CompetitionStatus status = CompetitionStatus.OPEN;

    @OneToMany(mappedBy = "competition", cascade = CascadeType.ALL)
    private List<Match> matches = new ArrayList<>();

    @OneToMany(mappedBy = "competition", cascade = CascadeType.ALL)
    private List<Participation> participations = new ArrayList<>();

    private Integer tournamentSize;
    private Integer requiredTeamSize;
}