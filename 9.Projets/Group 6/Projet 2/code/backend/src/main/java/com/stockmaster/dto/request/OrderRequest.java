package com.stockmaster.dto.request;

import com.stockmaster.domain.OrderType;
import jakarta.validation.constraints.*;
import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class OrderRequest {
    @NotNull
    private OrderType type;

    @NotEmpty
    private List<OrderItemRequest> items;

    @Data
    public static class OrderItemRequest {
        @NotNull
        private Long productId;
        @NotNull @Min(1)
        private Integer quantity;
        @NotNull @DecimalMin("0.0")
        private BigDecimal unitPrice;
    }
}
