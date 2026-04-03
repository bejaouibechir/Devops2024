package com.stockmaster.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class ProductRequest {
    @NotBlank
    private String code;
    @NotBlank
    private String name;
    private String description;
    @NotNull @DecimalMin("0.0")
    private BigDecimal unitPrice;
    private String unit;
    private String photoUrl;
    @Min(0)
    private Integer minStock = 0;
    @Min(0)
    private Integer maxStock = 1000;
    private Long categoryId;
    private Long supplierId;
}
