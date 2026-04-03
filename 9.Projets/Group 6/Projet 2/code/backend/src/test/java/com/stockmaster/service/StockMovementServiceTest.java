package com.stockmaster.service;

import com.stockmaster.domain.*;
import com.stockmaster.dto.request.StockMovementRequest;
import com.stockmaster.dto.response.StockMovementResponse;
import com.stockmaster.exception.InsufficientStockException;
import com.stockmaster.exception.ResourceNotFoundException;
import com.stockmaster.repository.ProductRepository;
import com.stockmaster.repository.StockMovementRepository;
import com.stockmaster.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class StockMovementServiceTest {

    @Mock
    private StockMovementRepository movementRepository;
    @Mock
    private ProductRepository productRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private AlertService alertService;

    @InjectMocks
    private StockMovementService stockMovementService;

    private Product product;
    private User user;

    @BeforeEach
    void setUp() {
        product = Product.builder()
                .id(1L).name("Widget").currentStock(100)
                .minStock(10).maxStock(500)
                .unitPrice(BigDecimal.TEN).build();
        user = User.builder().id(1L).username("john").role(Role.STOCK_MANAGER).build();
    }

    @Test
    void create_entry_increasesStock() {
        StockMovementRequest request = new StockMovementRequest();
        request.setProductId(1L);
        request.setType(MovementType.ENTRY);
        request.setQuantity(50);

        StockMovement saved = StockMovement.builder()
                .id(1L).product(product).type(MovementType.ENTRY)
                .quantity(50).user(user).build();

        when(productRepository.findById(1L)).thenReturn(Optional.of(product));
        when(userRepository.findByUsername("john")).thenReturn(Optional.of(user));
        when(productRepository.save(any())).thenReturn(product);
        when(movementRepository.save(any())).thenReturn(saved);

        StockMovementResponse result = stockMovementService.create(request, "john");

        assertThat(product.getCurrentStock()).isEqualTo(150);
        assertThat(result.getType()).isEqualTo(MovementType.ENTRY);
    }

    @Test
    void create_exit_decreasesStock() {
        StockMovementRequest request = new StockMovementRequest();
        request.setProductId(1L);
        request.setType(MovementType.EXIT);
        request.setQuantity(30);

        StockMovement saved = StockMovement.builder()
                .id(2L).product(product).type(MovementType.EXIT)
                .quantity(30).user(user).build();

        when(productRepository.findById(1L)).thenReturn(Optional.of(product));
        when(userRepository.findByUsername("john")).thenReturn(Optional.of(user));
        when(productRepository.save(any())).thenReturn(product);
        when(movementRepository.save(any())).thenReturn(saved);

        stockMovementService.create(request, "john");

        assertThat(product.getCurrentStock()).isEqualTo(70);
    }

    @Test
    void create_exit_insufficientStock_throwsException() {
        StockMovementRequest request = new StockMovementRequest();
        request.setProductId(1L);
        request.setType(MovementType.EXIT);
        request.setQuantity(200);

        when(productRepository.findById(1L)).thenReturn(Optional.of(product));
        when(userRepository.findByUsername("john")).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> stockMovementService.create(request, "john"))
                .isInstanceOf(InsufficientStockException.class);
    }

    @Test
    void create_adjustment_setsStockToQuantity() {
        StockMovementRequest request = new StockMovementRequest();
        request.setProductId(1L);
        request.setType(MovementType.ADJUSTMENT);
        request.setQuantity(75);

        StockMovement saved = StockMovement.builder()
                .id(3L).product(product).type(MovementType.ADJUSTMENT)
                .quantity(75).user(user).build();

        when(productRepository.findById(1L)).thenReturn(Optional.of(product));
        when(userRepository.findByUsername("john")).thenReturn(Optional.of(user));
        when(productRepository.save(any())).thenReturn(product);
        when(movementRepository.save(any())).thenReturn(saved);

        stockMovementService.create(request, "john");

        assertThat(product.getCurrentStock()).isEqualTo(75);
    }

    @Test
    void create_productNotFound_throwsException() {
        StockMovementRequest request = new StockMovementRequest();
        request.setProductId(99L);
        request.setType(MovementType.ENTRY);
        request.setQuantity(10);

        when(productRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> stockMovementService.create(request, "john"))
                .isInstanceOf(ResourceNotFoundException.class);
    }
}
