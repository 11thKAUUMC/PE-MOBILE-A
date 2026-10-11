// src/main/java/.../service/BookService.java
package com.umc.study.service;

import com.umc.study.dto.CreateBookRequest;
import com.umc.study.entity.Book;
import com.umc.study.entity.Category;
import com.umc.study.repository.BookRepository;
import com.umc.study.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import com.umc.study.dto.BookResponse;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service // 비즈니스 로직을 수행하는 서비스 계층
@RequiredArgsConstructor
public class BookService {

    // 창고지기(Repository)를 생성자 주입으로 데려옵니다.
    private final BookRepository bookRepository;
    private final CategoryRepository categoryRepository;

    @Transactional(readOnly = true)
    public List<BookResponse> getAllBooks() {
        // 지금은 별도 가공 없이 창고지기가 가져온 도서 목록을 그대로 반환합니다.
        return bookRepository.findAllByOrderByBookIdDesc()
                .stream()
                .map(BookResponse::from)
                .toList();
    }

    @Transactional
    public BookResponse createBook(CreateBookRequest request) {
        Category category = categoryRepository
                .findById(request.categoryId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "존재하지 않는 카테고리입니다."
                ));

        Book book = new Book(
                category,
                request.title(),
                request.description()
        );

        Book savedBook = bookRepository.save(book);

        return BookResponse.from(savedBook);
    }
}