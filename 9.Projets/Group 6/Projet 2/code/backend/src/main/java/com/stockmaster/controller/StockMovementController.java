package com.stockmaster.controller;

import com.stockmaster.dto.request.StockMovementRequest;
import com.stockmaster.dto.response.StockMovementResponse;
import com.stockmaster.service.StockMovementService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/stock-movements")
@RequiredArgsConstructor
public class StockMovementController {

    private final StockMovementService stockMovementService;

    @GetMapping
    public ResponseEntity<List<StockMovementResponse>> findAll() {
        return ResponseEntity.ok(stockMovementService.findAll());
    }

    @GetMapping("/product/{productId}")
    public ResponseEntity<List<StockMovementResponse>> findByProduct(@PathVariable Long productId) {
        return ResponseEntity.ok(stockMovementService.findByProduct(productId));
    }

    @PostMapping
    public ResponseEntity<StockMovementResponse> create(@Valid @RequestBody StockMovementRequest request,
                                                         Authentication authentication) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(stockMovementService.create(request, authentication.getName()));
    }
}
