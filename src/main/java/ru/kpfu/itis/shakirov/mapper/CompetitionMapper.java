package ru.kpfu.itis.shakirov.mapper;

import org.springframework.stereotype.Component;
import ru.kpfu.itis.shakirov.api.generated.dto.CompetitionResponse;
import ru.kpfu.itis.shakirov.dto.CompetitionDto;
import ru.kpfu.itis.shakirov.entity.Competition;
import ru.kpfu.itis.shakirov.entity.Match;
import ru.kpfu.itis.shakirov.entity.Participation;
import ru.kpfu.itis.shakirov.entity.Team;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class CompetitionMapper {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm");

    public CompetitionDto toDto(Competition c) {
        return CompetitionDto.builder()
                .id(c.getId())
                .title(c.getTitle())
                .address(c.getAddress())
                .disciplineName(c.getDiscipline().getName())
                .ownerLogin(c.getOwner().getLogin())
                .status(c.getStatus().name())
                .participantCount(c.getParticipations().size())
                .formattedDatetime(c.getDatetime().format(FORMATTER))
                .build();
    }

    public CompetitionResponse toResponse(Competition c) {
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

    public List<CompetitionDto> toDtoList(List<Competition> competitions) {
        return competitions.stream().map(this::toDto).collect(Collectors.toList());
    }

    public List<CompetitionResponse> toResponseList(List<Competition> competitions) {
        return competitions.stream().map(this::toResponse).collect(Collectors.toList());
    }
}