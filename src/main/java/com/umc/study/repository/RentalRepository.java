package com.umc.study.repository;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class RentalRepository {
    private final JdbcTemplate jdbcTemplate;

    // 2. 신규 도서 대여 기록 생성 API
    public void saveRental(Long userId, Long bookId) {
        String sql = "insert into rental (user_id, book_id, rented_at, due_at)" +
                " values (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY))";

        jdbcTemplate.update(sql, userId, bookId);
    }


}
