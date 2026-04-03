package com.stockmaster.repository;

import com.stockmaster.domain.MovementType;
import com.stockmaster.domain.StockMovement;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDateTime;
import java.util.List;

public interface StockMovementRepository extends JpaRepository<StockMovement, Long> {
    List<StockMovement> findByProductIdOrderByDateDesc(Long productId);
    List<StockMovement> findByType(MovementType type);
    List<StockMovement> findByDateBetweenOrderByDateDesc(LocalDateTime start, LocalDateTime end);
    List<StockMovement> findByUserId(Long userId);
}
