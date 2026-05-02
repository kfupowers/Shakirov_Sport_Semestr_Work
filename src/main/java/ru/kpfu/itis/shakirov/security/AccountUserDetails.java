package ru.kpfu.itis.shakirov.security;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import ru.kpfu.itis.shakirov.entity.Account;

import java.util.Collection;
import java.util.stream.Collectors;

public class AccountUserDetails implements UserDetails {

    private final Long id;
    private final String login;
    private final String password;
    private final String name;
    private final String surname;
    private final Collection<? extends GrantedAuthority> authorities;
    private final boolean enabled = true;

    public AccountUserDetails(Account account) {
        this.id = account.getId();
        this.login = account.getLogin();
        this.password = account.getPassword();
        this.name = account.getName();
        this.surname = account.getSurname();
        this.authorities = account.getRoles().stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role.getName()))
                .collect(Collectors.toList());
    }

    public Long getId() { return id; }
    public String getName() { return name; }
    public String getSurname() { return surname; }

    @Override
    public String getUsername() { return login; }

    @Override
    public String getPassword() { return password; }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() { return authorities; }

    @Override
    public boolean isAccountNonExpired() { return true; }
    @Override
    public boolean isAccountNonLocked() { return true; }
    @Override
    public boolean isCredentialsNonExpired() { return true; }
    @Override
    public boolean isEnabled() { return enabled; }
}