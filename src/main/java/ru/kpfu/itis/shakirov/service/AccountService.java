package ru.kpfu.itis.shakirov.service;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.kpfu.itis.shakirov.dto.RegistrationRequest;
import ru.kpfu.itis.shakirov.entity.Account;
import ru.kpfu.itis.shakirov.entity.Role;
import ru.kpfu.itis.shakirov.repository.AccountRepository;
import ru.kpfu.itis.shakirov.repository.RoleRepository;
import ru.kpfu.itis.shakirov.security.AccountUserDetails;

import java.util.HashSet;
import java.util.Set;

@Service
@RequiredArgsConstructor
@Slf4j
public class AccountService {
    private final AccountRepository accountRepo;
    private final RoleRepository roleRepo;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public Account register(RegistrationRequest request) {
        if (accountRepo.findByLogin(request.getLogin()).isPresent()) {
            throw new IllegalArgumentException("Login already taken");
        }
        Role userRole = roleRepo.findByName("USER")
                .orElseThrow(() -> new IllegalStateException("Role USER not found"));

        Account account = Account.builder()
                .login(request.getLogin())
                .name(request.getName())
                .surname(request.getSurname())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .birthDate(request.getBirthDate())
                .roles(new HashSet<>(Set.of(userRole)))
                .build();

        Account saved = accountRepo.save(account);
        log.info("Registered user '{}'", saved.getLogin());
        return saved;
    }

    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Account account = accountRepo.findByLogin(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
        return new AccountUserDetails(account);
    }


    public Account findByLogin(String login) {
        return accountRepo.findByLogin(login)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
    }

    public Account getAccountFromUserDetails(AccountUserDetails userDetails) {
        return accountRepo.findById(userDetails.getId())
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
    }
}