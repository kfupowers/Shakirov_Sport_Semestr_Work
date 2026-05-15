package ru.kpfu.itis.shakirov.dto;

import lombok.Builder;
import lombok.Data;
import java.io.Serializable;

@Data
@Builder
public class CompetitionDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String title;
    private String address;
    private String disciplineName;
    private String ownerLogin;
    private String status;
    private int participantCount;
    private String formattedDatetime;
}