package com.stockmaster.dto.request;

import com.stockmaster.domain.MovementType;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class StockMovementRequest {
    @NotNull
    private Long productId;
    @NotNull
    private MovementType type;
    @NotNull @Min(1)
    private Integer quantity;
    private String reason;
    private String reference;
}
