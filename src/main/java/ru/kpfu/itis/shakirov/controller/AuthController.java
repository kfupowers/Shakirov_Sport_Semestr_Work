package ru.kpfu.itis.shakirov.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import ru.kpfu.itis.shakirov.dto.RegistrationRequest;
import ru.kpfu.itis.shakirov.service.AccountService;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequiredArgsConstructor
public class AuthController {
    private final AccountService accountService;

    @GetMapping("/login")
    public String loginPage(@RequestParam(value = "error", required = false) String error,
                            @RequestParam(value = "logout", required = false) String logout,
                            Model model) {
        if (error != null) {
            model.addAttribute("loginError", "Неверный логин или пароль");
        }
        if (logout != null) {
            model.addAttribute("logoutMessage", "Вы вышли из системы");
        }
        return "login";
    }

    @GetMapping("/register")
    public String registerPage(Model model) {
        model.addAttribute("request", new RegistrationRequest());
        return "register";
    }

    @PostMapping("/register")
    public String register(@Valid @ModelAttribute("request") RegistrationRequest req,
                           BindingResult result, Model model) {
        Map<String, String> fieldErrors = new HashMap<>();
        if (result.hasErrors()) {
            fieldErrors = result.getFieldErrors().stream()
                    .collect(Collectors.toMap(FieldError::getField, e -> e.getDefaultMessage(), (m1, m2) -> m1));
        }

        if (!fieldErrors.isEmpty()) {
            model.addAttribute("errors", fieldErrors);
            return "register";
        }

        try {
            accountService.register(req);
        } catch (IllegalArgumentException ex) {
            if (ex.getMessage().contains("Login")) {
                fieldErrors.put("login", ex.getMessage());
            } else if (ex.getMessage().contains("Email")) {
                fieldErrors.put("email", ex.getMessage());
            } else {
                model.addAttribute("error", ex.getMessage());
                return "register";
            }
            model.addAttribute("errors", fieldErrors);
            return "register";
        }
        return "redirect:/login?registered";
    }
}