package ru.kpfu.itis.shakirov.repository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.criteria.*;
import org.springframework.stereotype.Repository;
import ru.kpfu.itis.shakirov.entity.Competition;
import ru.kpfu.itis.shakirov.entity.CompetitionStatus;
import ru.kpfu.itis.shakirov.entity.Discipline;

import java.util.ArrayList;
import java.util.List;

@Repository
public class CompetitionCriteriaRepository {
    @PersistenceContext
    private EntityManager em;

    public List<Competition> findByFilters(String disciplineName, CompetitionStatus status) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Competition> cq = cb.createQuery(Competition.class);
        Root<Competition> root = cq.from(Competition.class);
        List<Predicate> predicates = new ArrayList<>();
        if (disciplineName != null) {
            Join<Competition, Discipline> disc = root.join("discipline");
            predicates.add(cb.equal(disc.get("name"), disciplineName));
        }
        if (status != null) {
            predicates.add(cb.equal(root.get("status"), status));
        }
        cq.where(predicates.toArray(new Predicate[0]));
        return em.createQuery(cq).getResultList();
    }
}
