package com.stockmaster.controller;

import com.stockmaster.dto.response.AlertResponse;
import com.stockmaster.service.AlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/alerts")
@RequiredArgsConstructor
public class AlertController {

    private final AlertService alertService;

    @GetMapping
    public ResponseEntity<List<AlertResponse>> findAll() {
        return ResponseEntity.ok(alertService.findAll());
    }

    @GetMapping("/unread")
    public ResponseEntity<List<AlertResponse>> findUnread() {
        return ResponseEntity.ok(alertService.findUnread());
    }

    @GetMapping("/count")
    public ResponseEntity<Map<String, Long>> countUnread() {
        return ResponseEntity.ok(Map.of("unread", alertService.countUnread()));
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<AlertResponse> markAsRead(@PathVariable Long id) {
        return ResponseEntity.ok(alertService.markAsRead(id));
    }

    @PatchMapping("/read-all")
    public ResponseEntity<Void> markAllAsRead() {
        alertService.markAllAsRead();
        return ResponseEntity.noContent().build();
    }
}
