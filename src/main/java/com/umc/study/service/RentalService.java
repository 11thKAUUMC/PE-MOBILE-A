package com.umc.study.service;

import com.umc.study.repository.RentalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RentalService {

    private final RentalRepository rentalRepository;

    // 2. 신규 도서 대여 기록 생성 API
    public void createRental(Long userId, Long bookId) {
        rentalRepository.saveRental(userId, bookId);
    }
}
