package com.stockmaster.service;

import com.stockmaster.dto.response.ProductResponse;
import com.stockmaster.dto.response.StockMovementResponse;
import com.stockmaster.dto.response.StockSummaryResponse;
import com.stockmaster.repository.AlertRepository;
import com.stockmaster.repository.ProductRepository;
import com.stockmaster.repository.StockMovementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReportService {

    private final ProductRepository productRepository;
    private final StockMovementRepository movementRepository;
    private final AlertRepository alertRepository;
    private final ProductService productService;
    private final StockMovementService stockMovementService;

    @Cacheable("stock-summary")
    public StockSummaryResponse getStockSummary() {
        long total = productRepository.count();
        long outOfStock = productRepository.findOutOfStockProducts().size();
        long lowStock = productRepository.findLowStockProducts().size();
        long overstock = productRepository.findOverstockProducts().size();
        long unreadAlerts = alertRepository.countByIsReadFalse();
        return new StockSummaryResponse(total, outOfStock, lowStock, overstock, unreadAlerts);
    }

    public List<ProductResponse> getStockReport() {
        return productRepository.findAll().stream()
                .map(productService::toResponse).toList();
    }

    public List<StockMovementResponse> getMovementReport(LocalDateTime start, LocalDateTime end) {
        return stockMovementService.findByDateRange(start, end);
    }
}
