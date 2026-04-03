package com.stockmaster.service;

import com.stockmaster.domain.Category;
import com.stockmaster.exception.ResourceNotFoundException;
import com.stockmaster.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public List<Category> findAll() {
        return categoryRepository.findAll();
    }

    public Category findById(Long id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found: " + id));
    }

    public Category create(Category category) {
        if (categoryRepository.existsByName(category.getName())) {
            throw new IllegalArgumentException("Category already exists: " + category.getName());
        }
        return categoryRepository.save(category);
    }

    public Category update(Long id, Category updated) {
        Category category = findById(id);
        category.setName(updated.getName());
        category.setDescription(updated.getDescription());
        return categoryRepository.save(category);
    }

    public void delete(Long id) {
        findById(id);
        categoryRepository.deleteById(id);
    }
}
