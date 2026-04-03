package com.stockmaster.dto.response;

import com.stockmaster.domain.AlertType;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AlertResponse {
    private Long id;
    private Long productId;
    private String productName;
    private AlertType type;
    private String message;
    private LocalDateTime date;
    private boolean isRead;
}
