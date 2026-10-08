package com.umc11th.pemspring.repository;

import com.umc11th.pemspring.domain.Category;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, Long> {
}
