package ru.kpfu.itis.shakirov.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.format.FormatterRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import ru.kpfu.itis.shakirov.security.StringToCompetitionStatusConverter;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {
    private final StringToCompetitionStatusConverter converter;

    public WebMvcConfig(StringToCompetitionStatusConverter converter) {
        this.converter = converter;
    }

    @Override
    public void addFormatters(FormatterRegistry registry) {
        registry.addConverter(converter);
    }
}