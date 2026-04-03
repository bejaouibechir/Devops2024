package com.stockmaster.dto.response;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class ProductResponse {
    private Long id;
    private String code;
    private String name;
    private String description;
    private BigDecimal unitPrice;
    private String unit;
    private String photoUrl;
    private Integer currentStock;
    private Integer minStock;
    private Integer maxStock;
    private String categoryName;
    private String supplierName;
    private String stockStatus;
}
