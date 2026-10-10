package com.umc.study.controller;

import com.umc.study.service.RentalService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/rentals")
@RequiredArgsConstructor
public class RentalController {
    private final RentalService rentalService;

    // 2. 신규 도서 대여 기록 생성 API
    @PostMapping
    public String createRental(@RequestBody Map<String, Object> requestBody) {

        Long userId = ((Number) requestBody.get("userId")).longValue();
        Long bookId = ((Number) requestBody.get("bookId")).longValue();

        rentalService.createRental(userId, bookId);
        return "대여 기록이 성공적으로 생성되었습니다.";
    }
}
