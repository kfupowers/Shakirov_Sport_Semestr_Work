package ru.kpfu.itis.shakirov.dto;

import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;

@Data
public class CompetitionRequest {
    @NotBlank
    private String title;

    @NotNull(message = "Дата обязательна")
    @FutureOrPresent(message = "Дата должна быть в будущем или настоящем")
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime datetime;

    private String address;

    @NotNull
    private Long disciplineId;
}