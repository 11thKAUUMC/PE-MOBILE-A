package com.umc.movie.controller;

import com.umc.movie.dto.CheckResponse;
import com.umc.movie.service.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/members")
public class MemberController {

    private final MemberService memberService;

    @GetMapping("/nickname/{nickname}")
    public CheckResponse checkNickname(
            @PathVariable("nickname") String nickname
    ) {
        return memberService.checkNickname(nickname);
    }

    @GetMapping("/email/{email}")
    public CheckResponse checkEmail(
            @PathVariable("email") String email
    ) {
        return memberService.checkEmail(email);
    }
}