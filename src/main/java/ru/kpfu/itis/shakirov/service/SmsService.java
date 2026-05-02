package ru.kpfu.itis.shakirov.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

@Service
@Slf4j
public class SmsService {
    private final RestTemplate restTemplate = new RestTemplate();
    @Value("${sms.api.url}")
    private String apiUrl;

    public void sendVerificationCode(String phone, String code) {
        String url = UriComponentsBuilder.fromHttpUrl(apiUrl)
                .queryParam("api_id", "your_api_key")
                .queryParam("to", phone)
                .queryParam("msg", "Your verification code: " + code)
                .build().toUriString();
        try {
            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            log.info("SMS sent: {}", response.getStatusCode());
        } catch (Exception e) {
            log.error("Failed to send SMS", e);
            throw new RuntimeException("SMS service unavailable");
        }
    }
}
