package com.umc.movie.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 로그인한 회원의 memberId를 컨트롤러 파라미터로 주입합니다.
 * AuthInterceptor가 request에 담아둔 값을 ArgumentResolver가 꺼내줍니다.
 */
@Target(ElementType.PARAMETER)
@Retention(RetentionPolicy.RUNTIME)
public @interface LoginMember {
}
