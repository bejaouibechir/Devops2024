package com.stockmaster.repository;

import com.stockmaster.domain.Order;
import com.stockmaster.domain.OrderStatus;
import com.stockmaster.domain.OrderType;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {
    Optional<Order> findByReference(String reference);
    List<Order> findByType(OrderType type);
    List<Order> findByStatus(OrderStatus status);
    List<Order> findByTypeAndStatus(OrderType type, OrderStatus status);
    List<Order> findByCreatedById(Long userId);
}
