package com.umc.movie.service;

import com.umc.movie.dto.CheckResponse;
import com.umc.movie.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberService {

    private final MemberRepository memberRepository;

    public CheckResponse checkNickname(String nickname) {
        return new CheckResponse(
                !memberRepository.existsByNickname(nickname)
        );
    }

    public CheckResponse checkEmail(String email) {
        return new CheckResponse(
                !memberRepository.existsByEmail(email)
        );
    }
}