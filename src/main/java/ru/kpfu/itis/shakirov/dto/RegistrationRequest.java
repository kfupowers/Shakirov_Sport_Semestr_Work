package ru.kpfu.itis.shakirov.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

@Data
public class RegistrationRequest {
    @NotBlank
    @Size(min = 3, max = 100)
    private String login;
    @NotBlank @Size(min = 1)
    private String name;
    @NotBlank
    private String surname;
    @Email
    private String email;
    @NotBlank @Size(min = 6)
    private String password;
    @Past
    private LocalDate birthDate;
}
