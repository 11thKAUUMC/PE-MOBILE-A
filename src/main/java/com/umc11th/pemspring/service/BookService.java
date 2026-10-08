package com.umc11th.pemspring.service;

import com.umc11th.pemspring.domain.Book;
import com.umc11th.pemspring.domain.Category;
import com.umc11th.pemspring.dto.BookResponse;
import com.umc11th.pemspring.dto.CreateBookRequest;
import com.umc11th.pemspring.exception.BusinessException;
import com.umc11th.pemspring.repository.BookRepository;
import com.umc11th.pemspring.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BookService {

    private final BookRepository bookRepository;
    private final CategoryRepository categoryRepository;

    @Transactional(readOnly = true)
    public List<BookResponse> getBooks(String keyword) {
        List<Book> books = StringUtils.hasText(keyword)
                ? bookRepository.findByTitleContainingOrderByBookIdDesc(keyword)
                : bookRepository.findAllByOrderByBookIdDesc();
        return books.stream()
                .map(BookResponse::from)
                .toList();
    }

    @Transactional
    public BookResponse createBook(CreateBookRequest request) {
        if (bookRepository.existsByTitle(request.title())) {
            throw new BusinessException(HttpStatus.CONFLICT, "이미 등록된 도서 제목입니다.");
        }

        Category category = categoryRepository.findById(request.categoryId())
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "존재하지 않는 카테고리입니다."));

        Book book = new Book(category, request.title(), request.description());
        return BookResponse.from(bookRepository.save(book));
    }
}
