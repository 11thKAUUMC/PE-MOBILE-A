package com.umc11th.pemspring.service;

import com.umc11th.pemspring.repository.RentalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class RentalService {

    private final RentalRepository rentalRepository;

    public void createRental(Map<String, Object> body) {
        rentalRepository.save(body);
    }

    public int returnRental(Long rentalId) {
        return rentalRepository.updateReturnedAt(rentalId);
    }
}
