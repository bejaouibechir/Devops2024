package com.stockmaster.repository;

import com.stockmaster.domain.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, Long> {
    Optional<Product> findByCode(String code);
    boolean existsByCode(String code);
    List<Product> findByCategoryId(Long categoryId);
    List<Product> findBySupplierId(Long supplierId);

    @Query("SELECT p FROM Product p WHERE p.currentStock <= p.minStock")
    List<Product> findLowStockProducts();

    @Query("SELECT p FROM Product p WHERE p.currentStock = 0")
    List<Product> findOutOfStockProducts();

    @Query("SELECT p FROM Product p WHERE p.currentStock >= p.maxStock")
    List<Product> findOverstockProducts();
}
