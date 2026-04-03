package com.stockmaster.service;

import com.stockmaster.domain.Product;
import com.stockmaster.dto.request.ProductRequest;
import com.stockmaster.dto.response.ProductResponse;
import com.stockmaster.exception.ResourceNotFoundException;
import com.stockmaster.repository.CategoryRepository;
import com.stockmaster.repository.ProductRepository;
import com.stockmaster.repository.SupplierRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;
    @Mock
    private CategoryRepository categoryRepository;
    @Mock
    private SupplierRepository supplierRepository;

    @InjectMocks
    private ProductService productService;

    private Product product;

    @BeforeEach
    void setUp() {
        product = Product.builder()
                .id(1L)
                .code("PRD-001")
                .name("Test Product")
                .unitPrice(BigDecimal.valueOf(10.0))
                .currentStock(50)
                .minStock(10)
                .maxStock(200)
                .build();
    }

    @Test
    void findAll_returnsAllProducts() {
        when(productRepository.findAll()).thenReturn(List.of(product));

        List<ProductResponse> result = productService.findAll();

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getCode()).isEqualTo("PRD-001");
    }

    @Test
    void findById_existingId_returnsProduct() {
        when(productRepository.findById(1L)).thenReturn(Optional.of(product));

        ProductResponse result = productService.findById(1L);

        assertThat(result.getName()).isEqualTo("Test Product");
    }

    @Test
    void findById_nonExistingId_throwsException() {
        when(productRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> productService.findById(99L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("99");
    }

    @Test
    void create_duplicateCode_throwsException() {
        when(productRepository.existsByCode("PRD-001")).thenReturn(true);

        ProductRequest request = new ProductRequest();
        request.setCode("PRD-001");

        assertThatThrownBy(() -> productService.create(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("PRD-001");
    }

    @Test
    void create_validProduct_savesAndReturns() {
        ProductRequest request = new ProductRequest();
        request.setCode("PRD-002");
        request.setName("New Product");
        request.setUnitPrice(BigDecimal.valueOf(25.0));
        request.setMinStock(5);
        request.setMaxStock(100);

        Product saved = Product.builder().id(2L).code("PRD-002").name("New Product")
                .unitPrice(BigDecimal.valueOf(25.0)).currentStock(0).minStock(5).maxStock(100).build();

        when(productRepository.existsByCode("PRD-002")).thenReturn(false);
        when(productRepository.save(any(Product.class))).thenReturn(saved);

        ProductResponse result = productService.create(request);

        assertThat(result.getCode()).isEqualTo("PRD-002");
        verify(productRepository).save(any(Product.class));
    }

    @Test
    void delete_existingProduct_deletesSuccessfully() {
        when(productRepository.findById(1L)).thenReturn(Optional.of(product));

        productService.delete(1L);

        verify(productRepository).deleteById(1L);
    }

    @Test
    void toResponse_lowStock_setsCorrectStatus() {
        product.setCurrentStock(5);
        product.setMinStock(10);

        ProductResponse response = productService.toResponse(product);

        assertThat(response.getStockStatus()).isEqualTo("LOW_STOCK");
    }

    @Test
    void toResponse_outOfStock_setsCorrectStatus() {
        product.setCurrentStock(0);

        ProductResponse response = productService.toResponse(product);

        assertThat(response.getStockStatus()).isEqualTo("OUT_OF_STOCK");
    }

    @Test
    void toResponse_normalStock_setsOkStatus() {
        product.setCurrentStock(50);
        product.setMinStock(10);
        product.setMaxStock(200);

        ProductResponse response = productService.toResponse(product);

        assertThat(response.getStockStatus()).isEqualTo("OK");
    }
}
