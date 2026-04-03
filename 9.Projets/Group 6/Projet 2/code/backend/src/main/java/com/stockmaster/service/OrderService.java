package com.stockmaster.service;

import com.stockmaster.domain.*;
import com.stockmaster.dto.request.OrderRequest;
import com.stockmaster.dto.response.OrderResponse;
import com.stockmaster.exception.ResourceNotFoundException;
import com.stockmaster.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class OrderService {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    public OrderResponse create(OrderRequest request, String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Order order = Order.builder()
                .reference(generateReference(request.getType()))
                .type(request.getType())
                .status(OrderStatus.PENDING)
                .date(LocalDateTime.now())
                .createdBy(user)
                .build();

        for (OrderRequest.OrderItemRequest itemReq : request.getItems()) {
            Product product = productRepository.findById(itemReq.getProductId())
                    .orElseThrow(() -> new ResourceNotFoundException("Product not found: " + itemReq.getProductId()));
            OrderItem item = OrderItem.builder()
                    .order(order)
                    .product(product)
                    .quantity(itemReq.getQuantity())
                    .unitPrice(itemReq.getUnitPrice())
                    .build();
            order.getItems().add(item);
        }

        return toResponse(orderRepository.save(order));
    }

    public OrderResponse findById(Long id) {
        return toResponse(getOrThrow(id));
    }

    public List<OrderResponse> findAll() {
        return orderRepository.findAll().stream().map(this::toResponse).toList();
    }

    public List<OrderResponse> findByType(OrderType type) {
        return orderRepository.findByType(type).stream().map(this::toResponse).toList();
    }

    public OrderResponse updateStatus(Long id, OrderStatus status) {
        Order order = getOrThrow(id);
        order.setStatus(status);
        return toResponse(orderRepository.save(order));
    }

    private Order getOrThrow(Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found: " + id));
    }

    private String generateReference(OrderType type) {
        String prefix = type == OrderType.SUPPLIER ? "SUP" : "CUS";
        String date = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        return prefix + "-" + date + "-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();
    }

    private OrderResponse toResponse(Order o) {
        OrderResponse r = new OrderResponse();
        r.setId(o.getId());
        r.setReference(o.getReference());
        r.setType(o.getType());
        r.setStatus(o.getStatus());
        r.setDate(o.getDate());
        if (o.getCreatedBy() != null) r.setCreatedBy(o.getCreatedBy().getUsername());
        r.setItems(o.getItems().stream().map(item -> {
            OrderResponse.OrderItemResponse ir = new OrderResponse.OrderItemResponse();
            ir.setProductId(item.getProduct().getId());
            ir.setProductName(item.getProduct().getName());
            ir.setQuantity(item.getQuantity());
            ir.setUnitPrice(item.getUnitPrice());
            return ir;
        }).toList());
        r.setTotalAmount(o.getItems().stream()
                .map(i -> i.getUnitPrice().multiply(BigDecimal.valueOf(i.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add));
        return r;
    }
}
