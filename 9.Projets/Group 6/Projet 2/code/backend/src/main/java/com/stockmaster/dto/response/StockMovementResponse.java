package com.stockmaster.dto.response;

import com.stockmaster.domain.MovementType;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class StockMovementResponse {
    private Long id;
    private Long productId;
    private String productName;
    private MovementType type;
    private Integer quantity;
    private LocalDateTime date;
    private String username;
    private String reason;
    private String reference;
}
