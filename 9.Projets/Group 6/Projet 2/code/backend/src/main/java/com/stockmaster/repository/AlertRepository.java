package com.stockmaster.repository;

import com.stockmaster.domain.Alert;
import com.stockmaster.domain.AlertType;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AlertRepository extends JpaRepository<Alert, Long> {
    List<Alert> findByIsReadFalseOrderByDateDesc();
    List<Alert> findByProductId(Long productId);
    List<Alert> findByType(AlertType type);
    long countByIsReadFalse();
}
