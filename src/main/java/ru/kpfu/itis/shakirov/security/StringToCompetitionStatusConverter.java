package ru.kpfu.itis.shakirov.security;

import org.springframework.core.convert.converter.Converter;
import org.springframework.stereotype.Component;
import ru.kpfu.itis.shakirov.entity.CompetitionStatus;

@Component
public class StringToCompetitionStatusConverter implements Converter<String, CompetitionStatus> {
    @Override
    public CompetitionStatus convert(String source) {
        if (source == null || source.isBlank()) return null;
        return CompetitionStatus.valueOf(source.toUpperCase());
    }
}
