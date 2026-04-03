package com.stockmaster.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class StockSummaryResponse {
    private long totalProducts;
    private long outOfStock;
    private long lowStock;
    private long overstock;
    private long unreadAlerts;
}
