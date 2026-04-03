package com.stockmaster.service;

import com.stockmaster.domain.*;
import com.stockmaster.dto.request.StockMovementRequest;
import com.stockmaster.dto.response.StockMovementResponse;
import com.stockmaster.exception.InsufficientStockException;
import com.stockmaster.exception.ResourceNotFoundException;
import com.stockmaster.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class StockMovementService {

    private final StockMovementRepository movementRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final AlertService alertService;

    public StockMovementResponse create(StockMovementRequest request, String username) {
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        applyMovement(product, request.getType(), request.getQuantity());
        productRepository.save(product);
        alertService.checkAndCreateAlerts(product);

        StockMovement movement = StockMovement.builder()
                .product(product)
                .type(request.getType())
                .quantity(request.getQuantity())
                .date(LocalDateTime.now())
                .user(user)
                .reason(request.getReason())
                .reference(request.getReference())
                .build();

        return toResponse(movementRepository.save(movement));
    }

    public List<StockMovementResponse> findAll() {
        return movementRepository.findAll().stream().map(this::toResponse).toList();
    }

    public List<StockMovementResponse> findByProduct(Long productId) {
        return movementRepository.findByProductIdOrderByDateDesc(productId)
                .stream().map(this::toResponse).toList();
    }

    public List<StockMovementResponse> findByDateRange(LocalDateTime start, LocalDateTime end) {
        return movementRepository.findByDateBetweenOrderByDateDesc(start, end)
                .stream().map(this::toResponse).toList();
    }

    private void applyMovement(Product product, MovementType type, int quantity) {
        switch (type) {
            case ENTRY -> product.setCurrentStock(product.getCurrentStock() + quantity);
            case EXIT -> {
                if (product.getCurrentStock() < quantity) {
                    throw new InsufficientStockException(
                            "Insufficient stock for product: " + product.getName() +
                            ". Available: " + product.getCurrentStock());
                }
                product.setCurrentStock(product.getCurrentStock() - quantity);
            }
            case ADJUSTMENT -> product.setCurrentStock(quantity);
        }
    }

    private StockMovementResponse toResponse(StockMovement m) {
        StockMovementResponse r = new StockMovementResponse();
        r.setId(m.getId());
        r.setProductId(m.getProduct().getId());
        r.setProductName(m.getProduct().getName());
        r.setType(m.getType());
        r.setQuantity(m.getQuantity());
        r.setDate(m.getDate());
        if (m.getUser() != null) r.setUsername(m.getUser().getUsername());
        r.setReason(m.getReason());
        r.setReference(m.getReference());
        return r;
    }
}
