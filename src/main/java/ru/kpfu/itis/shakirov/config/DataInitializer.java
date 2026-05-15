package ru.kpfu.itis.shakirov.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import ru.kpfu.itis.shakirov.entity.Discipline;
import ru.kpfu.itis.shakirov.entity.Role;
import ru.kpfu.itis.shakirov.repository.DisciplineRepository;
import ru.kpfu.itis.shakirov.repository.RoleRepository;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements ApplicationRunner {

    private final RoleRepository roleRepo;
    private final DisciplineRepository disciplineRepo;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (roleRepo.count() == 0) {
            roleRepo.save(new Role(null, "USER"));
            roleRepo.save(new Role(null, "ORGANIZER"));
            roleRepo.save(new Role(null, "ADMIN"));
            log.info("Roles initialized");
        }
        if (disciplineRepo.count() == 0) {
            disciplineRepo.save(new Discipline(null, "Футбол"));
            disciplineRepo.save(new Discipline(null, "Теннис"));
            disciplineRepo.save(new Discipline(null, "Баскетбол"));
            log.info("Disciplines initialized");
        }
    }
}