package com.umc.movie.controller;

import com.umc.movie.dto.ApiResponse;
import com.umc.movie.exception.BusinessException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidation(MethodArgumentNotValidException exception) {
        String message = exception.getBindingResult().getFieldErrors().get(0).getDefaultMessage();
        return ResponseEntity.badRequest().body(ApiResponse.failure("COMMON4001", message));
    }

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<Void>> handleBusiness(BusinessException exception) {
        return ResponseEntity.status(exception.getStatus())
                .body(ApiResponse.failure(exception.getCode(), exception.getMessage()));
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiResponse<Void>> handleDataIntegrity(DataIntegrityViolationException exception) {
        String detail = extractDetail(exception);

        if (containsAny(detail, "email", "uk_member_email", "member.email")) {
            return ResponseEntity.status(409)
                    .body(ApiResponse.failure("MEMBER4091", "이미 사용 중인 이메일입니다."));
        }
        if (containsAny(detail, "nickname", "uk_member_nickname", "member.nickname")) {
            return ResponseEntity.status(409)
                    .body(ApiResponse.failure("MEMBER4092", "이미 사용 중인 닉네임입니다."));
        }
        if (containsAny(detail, "movie_id", "member_id", "rating", "uk_rating")) {
            return ResponseEntity.status(409)
                    .body(ApiResponse.failure("RATING4091", "이미 이 영화에 평점을 남기셨습니다."));
        }

        return ResponseEntity.status(409)
                .body(ApiResponse.failure("COMMON4091", "이미 존재하는 데이터입니다."));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<Void>> handleIllegalArgument(IllegalArgumentException exception) {
        return ResponseEntity.status(409).body(ApiResponse.failure("COMMON4092", exception.getMessage()));
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<ApiResponse<Void>> handleResponseStatus(ResponseStatusException exception) {
        int status = exception.getStatusCode().value();
        return ResponseEntity.status(status)
                .body(ApiResponse.failure("COMMON" + status, exception.getReason()));
    }

    private String extractDetail(DataIntegrityViolationException exception) {
        StringBuilder detail = new StringBuilder();
        if (exception.getMessage() != null) {
            detail.append(exception.getMessage());
        }
        if (exception.getMostSpecificCause() != null
                && exception.getMostSpecificCause().getMessage() != null) {
            detail.append(' ').append(exception.getMostSpecificCause().getMessage());
        }
        return detail.toString().toLowerCase();
    }

    private boolean containsAny(String detail, String... keywords) {
        for (String keyword : keywords) {
            if (detail.contains(keyword.toLowerCase())) {
                return true;
            }
        }
        return false;
    }
}
