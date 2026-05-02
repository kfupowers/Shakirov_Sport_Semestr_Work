package ru.kpfu.itis.shakirov.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class CompetitionDto {
    private Long id;
    private String title;
    private String address;
    private String disciplineName;
    private String ownerLogin;
    private String status;
    private int participantCount;
    private String formattedDatetime;
}