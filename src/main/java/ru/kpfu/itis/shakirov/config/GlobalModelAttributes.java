package ru.kpfu.itis.shakirov.config;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;
import ru.kpfu.itis.shakirov.security.AccountUserDetails;

@ControllerAdvice
public class GlobalModelAttributes {

    @ModelAttribute("user")
    public AccountUserDetails currentUser(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() instanceof AccountUserDetails user) {
            return user;
        }
        return null;
    }
}