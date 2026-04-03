package com.stockmaster.dto.response;

import com.stockmaster.domain.OrderStatus;
import com.stockmaster.domain.OrderType;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class OrderResponse {
    private Long id;
    private String reference;
    private OrderType type;
    private OrderStatus status;
    private LocalDateTime date;
    private String createdBy;
    private List<OrderItemResponse> items;
    private BigDecimal totalAmount;

    @Data
    public static class OrderItemResponse {
        private Long productId;
        private String productName;
        private Integer quantity;
        private BigDecimal unitPrice;
    }
}
