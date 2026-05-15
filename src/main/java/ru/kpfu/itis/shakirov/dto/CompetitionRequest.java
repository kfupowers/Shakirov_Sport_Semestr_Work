package ru.kpfu.itis.shakirov.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CompetitionRequest {
    @NotBlank
    private String title;

    @NotNull
    @Future(message = "Дата начала должна быть в будущем")
    private LocalDateTime datetime;

    @NotBlank(message = "Адрес не может быть пустым")
    private String address;

    @NotNull
    private Long disciplineId;

    @NotNull @Min(2)
    private Integer tournamentSize;

    @NotNull @Min(1)
    private Integer requiredTeamSize;
}