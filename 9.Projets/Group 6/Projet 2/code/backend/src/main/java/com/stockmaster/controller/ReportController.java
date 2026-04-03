package com.stockmaster.controller;

import com.stockmaster.dto.response.ProductResponse;
import com.stockmaster.dto.response.StockMovementResponse;
import com.stockmaster.dto.response.StockSummaryResponse;
import com.stockmaster.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    @GetMapping("/summary")
    public ResponseEntity<StockSummaryResponse> getSummary() {
        return ResponseEntity.ok(reportService.getStockSummary());
    }

    @GetMapping("/stock")
    @PreAuthorize("hasAnyRole('STOCK_MANAGER', 'ACCOUNTANT')")
    public ResponseEntity<List<ProductResponse>> getStockReport() {
        return ResponseEntity.ok(reportService.getStockReport());
    }

    @GetMapping("/movements")
    @PreAuthorize("hasAnyRole('STOCK_MANAGER', 'ACCOUNTANT')")
    public ResponseEntity<List<StockMovementResponse>> getMovementReport(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        return ResponseEntity.ok(reportService.getMovementReport(start, end));
    }
}
