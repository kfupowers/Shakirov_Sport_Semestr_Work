package ru.kpfu.itis.shakirov.service;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
public class AddressService {

    private final RestTemplate restTemplate = new RestTemplate();
    @Value("${dadata.api.url}")
    private String apiUrl;
    @Value("${dadata.api.key}")
    private String apiKey;

    public boolean isValidAddress(String address) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "Token " + apiKey);
            headers.set("Content-Type", "application/json");
            Map<String, String> body = Map.of("query", address);
            HttpEntity<Map<String, String>> request = new HttpEntity<>(body, headers);
            ResponseEntity<DaDataResponse> response = restTemplate.exchange(
                    apiUrl, HttpMethod.POST, request, DaDataResponse.class);
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                List<Suggestion> suggestions = response.getBody().getSuggestions();
                return suggestions != null && !suggestions.isEmpty();
            }
        } catch (Exception e) {
            return false;
        }
        return false;
    }

    @Data
    public static class DaDataResponse {
        private List<Suggestion> suggestions;
    }

    @Data
    public static class Suggestion {
        private String value;
        @JsonProperty("unrestricted_value")
        private String unrestrictedValue;
        private AddressData data;
    }

    @Data
    public static class AddressData {
        @JsonProperty("geo_lat")
        private Double geoLat;
        @JsonProperty("geo_lon")
        private Double geoLon;
    }
}