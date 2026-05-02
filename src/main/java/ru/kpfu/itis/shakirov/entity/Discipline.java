package ru.kpfu.itis.shakirov.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "discipline", schema = "sport")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Discipline {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String name;
}