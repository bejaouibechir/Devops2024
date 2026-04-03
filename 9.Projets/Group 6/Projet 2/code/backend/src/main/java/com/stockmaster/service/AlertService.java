package com.stockmaster.service;

import com.stockmaster.domain.*;
import com.stockmaster.dto.response.AlertResponse;
import com.stockmaster.exception.ResourceNotFoundException;
import com.stockmaster.repository.AlertRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class AlertService {

    private final AlertRepository alertRepository;

    public void checkAndCreateAlerts(Product product) {
        if (product.getCurrentStock() == 0) {
            createAlert(product, AlertType.OUT_OF_STOCK,
                    "Product '" + product.getName() + "' is out of stock");
        } else if (product.getCurrentStock() <= product.getMinStock()) {
            createAlert(product, AlertType.LOW_STOCK,
                    "Low stock for '" + product.getName() + "': " + product.getCurrentStock() + " remaining");
        } else if (product.getCurrentStock() >= product.getMaxStock()) {
            createAlert(product, AlertType.OVERSTOCK,
                    "Overstock for '" + product.getName() + "': " + product.getCurrentStock() + " units");
        }
    }

    private void createAlert(Product product, AlertType type, String message) {
        Alert alert = Alert.builder()
                .product(product)
                .type(type)
                .message(message)
                .date(LocalDateTime.now())
                .isRead(false)
                .build();
        alertRepository.save(alert);
    }

    public List<AlertResponse> findUnread() {
        return alertRepository.findByIsReadFalseOrderByDateDesc()
                .stream().map(this::toResponse).toList();
    }

    public List<AlertResponse> findAll() {
        return alertRepository.findAll().stream().map(this::toResponse).toList();
    }

    public AlertResponse markAsRead(Long id) {
        Alert alert = alertRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Alert not found: " + id));
        alert.setRead(true);
        return toResponse(alertRepository.save(alert));
    }

    public void markAllAsRead() {
        List<Alert> unread = alertRepository.findByIsReadFalseOrderByDateDesc();
        unread.forEach(a -> a.setRead(true));
        alertRepository.saveAll(unread);
    }

    public long countUnread() {
        return alertRepository.countByIsReadFalse();
    }

    private AlertResponse toResponse(Alert a) {
        AlertResponse r = new AlertResponse();
        r.setId(a.getId());
        r.setProductId(a.getProduct().getId());
        r.setProductName(a.getProduct().getName());
        r.setType(a.getType());
        r.setMessage(a.getMessage());
        r.setDate(a.getDate());
        r.setRead(a.isRead());
        return r;
    }
}
