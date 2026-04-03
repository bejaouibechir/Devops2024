package com.stockmaster.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.stockmaster.dto.request.ProductRequest;
import com.stockmaster.dto.response.ProductResponse;
import com.stockmaster.exception.GlobalExceptionHandler;
import com.stockmaster.exception.ResourceNotFoundException;
import com.stockmaster.service.ProductService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.List;

import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(ProductController.class)
@Import(GlobalExceptionHandler.class)
class ProductControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private ProductService productService;

    @Test
    @WithMockUser
    void findAll_returnsProductList() throws Exception {
        ProductResponse product = new ProductResponse();
        product.setId(1L);
        product.setCode("PRD-001");
        product.setName("Widget");
        product.setStockStatus("OK");

        when(productService.findAll()).thenReturn(List.of(product));

        mockMvc.perform(get("/api/products"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].code").value("PRD-001"));
    }

    @Test
    @WithMockUser
    void findById_notFound_returns404() throws Exception {
        when(productService.findById(99L)).thenThrow(new ResourceNotFoundException("Product not found: 99"));

        mockMvc.perform(get("/api/products/99"))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(roles = "STOCK_MANAGER")
    void create_validRequest_returns201() throws Exception {
        ProductRequest request = new ProductRequest();
        request.setCode("PRD-003");
        request.setName("New Item");
        request.setUnitPrice(BigDecimal.valueOf(9.99));
        request.setMinStock(5);
        request.setMaxStock(100);

        ProductResponse response = new ProductResponse();
        response.setId(3L);
        response.setCode("PRD-003");
        response.setName("New Item");

        when(productService.create(any(ProductRequest.class))).thenReturn(response);

        mockMvc.perform(post("/api/products")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.code").value("PRD-003"));
    }

    @Test
    @WithMockUser(roles = "STOCK_MANAGER")
    void delete_existingProduct_returns204() throws Exception {
        doNothing().when(productService).delete(1L);

        mockMvc.perform(delete("/api/products/1").with(csrf()))
                .andExpect(status().isNoContent());
    }
}
