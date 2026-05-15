package ru.kpfu.itis.shakirov.dto;

import lombok.Builder;
import lombok.Data;
import ru.kpfu.itis.shakirov.entity.Competition;
import ru.kpfu.itis.shakirov.entity.Match;
import ru.kpfu.itis.shakirov.entity.Participation;
import ru.kpfu.itis.shakirov.entity.Team;

import java.util.List;

@Data
@Builder
public class CompetitionViewDto {
    private Competition competition;
    private List<Team> userTeams;
    private List<Participation> participations;
    private List<Match> matches;
    private String formattedDatetime;
}