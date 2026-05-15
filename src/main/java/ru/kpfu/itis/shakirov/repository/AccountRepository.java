package ru.kpfu.itis.shakirov.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.kpfu.itis.shakirov.entity.Account;
import java.util.Optional;

public interface AccountRepository extends JpaRepository<Account, Long> {
    Optional<Account> findByLogin(String login);
    Optional<Account> findByEmail(String email);
}