package ru.kpfu.itis.shakirov.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "match", schema = "sport")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Match {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "competition_id")
    private Competition competition;

    private Integer round;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "first_team_id")
    private Team firstTeam;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "second_team_id")
    private Team secondTeam;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "winner_team_id")
    private Team winnerTeam;

    private Integer score1;
    private Integer score2;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "next_match_id")
    private Match nextMatch;
}
