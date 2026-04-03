package com.stockmaster.service;

import com.stockmaster.domain.Product;
import com.stockmaster.dto.request.ProductRequest;
import com.stockmaster.dto.response.ProductResponse;
import com.stockmaster.exception.ResourceNotFoundException;
import com.stockmaster.repository.CategoryRepository;
import com.stockmaster.repository.ProductRepository;
import com.stockmaster.repository.SupplierRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final SupplierRepository supplierRepository;

    @Cacheable("products")
    public List<ProductResponse> findAll() {
        return productRepository.findAll().stream().map(this::toResponse).toList();
    }

    public ProductResponse findById(Long id) {
        return toResponse(getOrThrow(id));
    }

    @CacheEvict(value = "products", allEntries = true)
    public ProductResponse create(ProductRequest request) {
        if (productRepository.existsByCode(request.getCode())) {
            throw new IllegalArgumentException("Product code already exists: " + request.getCode());
        }
        return toResponse(productRepository.save(toEntity(request)));
    }

    @CacheEvict(value = "products", allEntries = true)
    public ProductResponse update(Long id, ProductRequest request) {
        Product product = getOrThrow(id);
        product.setName(request.getName());
        product.setDescription(request.getDescription());
        product.setUnitPrice(request.getUnitPrice());
        product.setUnit(request.getUnit());
        product.setPhotoUrl(request.getPhotoUrl());
        product.setMinStock(request.getMinStock());
        product.setMaxStock(request.getMaxStock());
        if (request.getCategoryId() != null) {
            product.setCategory(categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Category not found")));
        }
        if (request.getSupplierId() != null) {
            product.setSupplier(supplierRepository.findById(request.getSupplierId())
                    .orElseThrow(() -> new ResourceNotFoundException("Supplier not found")));
        }
        return toResponse(productRepository.save(product));
    }

    @CacheEvict(value = "products", allEntries = true)
    public void delete(Long id) {
        getOrThrow(id);
        productRepository.deleteById(id);
    }

    public List<ProductResponse> findLowStock() {
        return productRepository.findLowStockProducts().stream().map(this::toResponse).toList();
    }

    public List<ProductResponse> findOutOfStock() {
        return productRepository.findOutOfStockProducts().stream().map(this::toResponse).toList();
    }

    private Product getOrThrow(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found: " + id));
    }

    private Product toEntity(ProductRequest req) {
        Product p = new Product();
        p.setCode(req.getCode());
        p.setName(req.getName());
        p.setDescription(req.getDescription());
        p.setUnitPrice(req.getUnitPrice());
        p.setUnit(req.getUnit());
        p.setPhotoUrl(req.getPhotoUrl());
        p.setMinStock(req.getMinStock());
        p.setMaxStock(req.getMaxStock());
        p.setCurrentStock(0);
        if (req.getCategoryId() != null) {
            p.setCategory(categoryRepository.findById(req.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Category not found")));
        }
        if (req.getSupplierId() != null) {
            p.setSupplier(supplierRepository.findById(req.getSupplierId())
                    .orElseThrow(() -> new ResourceNotFoundException("Supplier not found")));
        }
        return p;
    }

    public ProductResponse toResponse(Product p) {
        ProductResponse r = new ProductResponse();
        r.setId(p.getId());
        r.setCode(p.getCode());
        r.setName(p.getName());
        r.setDescription(p.getDescription());
        r.setUnitPrice(p.getUnitPrice());
        r.setUnit(p.getUnit());
        r.setPhotoUrl(p.getPhotoUrl());
        r.setCurrentStock(p.getCurrentStock());
        r.setMinStock(p.getMinStock());
        r.setMaxStock(p.getMaxStock());
        if (p.getCategory() != null) r.setCategoryName(p.getCategory().getName());
        if (p.getSupplier() != null) r.setSupplierName(p.getSupplier().getName());
        if (p.getCurrentStock() == 0) r.setStockStatus("OUT_OF_STOCK");
        else if (p.getCurrentStock() <= p.getMinStock()) r.setStockStatus("LOW_STOCK");
        else if (p.getCurrentStock() >= p.getMaxStock()) r.setStockStatus("OVERSTOCK");
        else r.setStockStatus("OK");
        return r;
    }
}
