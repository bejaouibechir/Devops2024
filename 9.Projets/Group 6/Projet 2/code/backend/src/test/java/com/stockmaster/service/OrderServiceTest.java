package com.stockmaster.service;

import com.stockmaster.domain.*;
import com.stockmaster.dto.request.OrderRequest;
import com.stockmaster.dto.response.OrderResponse;
import com.stockmaster.exception.ResourceNotFoundException;
import com.stockmaster.repository.OrderRepository;
import com.stockmaster.repository.ProductRepository;
import com.stockmaster.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;
    @Mock
    private ProductRepository productRepository;
    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private OrderService orderService;

    private User user;
    private Product product;

    @BeforeEach
    void setUp() {
        user = User.builder().id(1L).username("buyer").role(Role.BUYER).build();
        product = Product.builder().id(1L).name("Widget")
                .unitPrice(BigDecimal.valueOf(15.0)).build();
    }

    @Test
    void create_supplierOrder_returnsOrderWithReference() {
        OrderRequest.OrderItemRequest itemReq = new OrderRequest.OrderItemRequest();
        itemReq.setProductId(1L);
        itemReq.setQuantity(10);
        itemReq.setUnitPrice(BigDecimal.valueOf(15.0));

        OrderRequest request = new OrderRequest();
        request.setType(OrderType.SUPPLIER);
        request.setItems(List.of(itemReq));

        Order savedOrder = Order.builder()
                .id(1L).reference("SUP-20260101-ABC123")
                .type(OrderType.SUPPLIER).status(OrderStatus.PENDING)
                .date(LocalDateTime.now()).createdBy(user).items(new ArrayList<>()).build();

        when(userRepository.findByUsername("buyer")).thenReturn(Optional.of(user));
        when(productRepository.findById(1L)).thenReturn(Optional.of(product));
        when(orderRepository.save(any(Order.class))).thenReturn(savedOrder);

        OrderResponse result = orderService.create(request, "buyer");

        assertThat(result.getStatus()).isEqualTo(OrderStatus.PENDING);
        assertThat(result.getType()).isEqualTo(OrderType.SUPPLIER);
    }

    @Test
    void updateStatus_existingOrder_updatesStatus() {
        Order order = Order.builder().id(1L).reference("REF-001")
                .type(OrderType.CUSTOMER).status(OrderStatus.PENDING)
                .date(LocalDateTime.now()).items(new ArrayList<>()).build();

        when(orderRepository.findById(1L)).thenReturn(Optional.of(order));
        when(orderRepository.save(any(Order.class))).thenReturn(order);

        OrderResponse result = orderService.updateStatus(1L, OrderStatus.VALIDATED);

        assertThat(result.getStatus()).isEqualTo(OrderStatus.VALIDATED);
    }

    @Test
    void findById_nonExisting_throwsException() {
        when(orderRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> orderService.findById(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void findByType_returnsFilteredOrders() {
        Order order = Order.builder().id(1L).reference("CUS-001")
                .type(OrderType.CUSTOMER).status(OrderStatus.PENDING)
                .date(LocalDateTime.now()).items(new ArrayList<>()).build();

        when(orderRepository.findByType(OrderType.CUSTOMER)).thenReturn(List.of(order));

        List<OrderResponse> result = orderService.findByType(OrderType.CUSTOMER);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getType()).isEqualTo(OrderType.CUSTOMER);
    }
}
