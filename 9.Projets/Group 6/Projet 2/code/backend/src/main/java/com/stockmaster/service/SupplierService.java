package com.stockmaster.service;

import com.stockmaster.domain.Supplier;
import com.stockmaster.exception.ResourceNotFoundException;
import com.stockmaster.repository.SupplierRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class SupplierService {

    private final SupplierRepository supplierRepository;

    public List<Supplier> findAll() {
        return supplierRepository.findAll();
    }

    public Supplier findById(Long id) {
        return supplierRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Supplier not found: " + id));
    }

    public Supplier create(Supplier supplier) {
        return supplierRepository.save(supplier);
    }

    public Supplier update(Long id, Supplier updated) {
        Supplier supplier = findById(id);
        supplier.setName(updated.getName());
        supplier.setEmail(updated.getEmail());
        supplier.setPhone(updated.getPhone());
        supplier.setAddress(updated.getAddress());
        return supplierRepository.save(supplier);
    }

    public void delete(Long id) {
        findById(id);
        supplierRepository.deleteById(id);
    }
}
