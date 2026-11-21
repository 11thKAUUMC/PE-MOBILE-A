# 8주차 BE 실습

NestJS와 MySQL 8.4를 사용했다. 5주차의 `member`, `rating`, `favorite` 테이블을 그대로 사용한다. 빈 실습 DB에는 [schema.sql](schema.sql)을 적용한다. 기존 DB에서는 `SHOW CREATE TABLE favorite`로 `uk_favorite_member_movie (member_id, movie_id)`가 있는지 확인한다.

Node 24.22.1에서 아래 명령을 실행한다. `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, 32자 이상의 `JWT_SECRET`을 환경 변수로 지정한다.

```bash
npm ci
npm run build
npm exec -- oxlint --type-aware src/
PORT=3088 npm run start:prod
```

- Swagger UI는 `http://127.0.0.1:3088/docs`에서 연다. `POST /auth/login`으로 받은 토큰을 Swagger의 **Authorize**에 입력한다.
- Postman에서는 실행마다 실습 회원 A와 B를 가입시킨다. 컬렉션의 `baseUrl`을 바꾸면 다른 실습 서버에서도 실행할 수 있다.

```bash
postman collection run docs/week08/week08.postman_collection.json --no-report-events
```

## 제출물

| 검증 | 결과 |
| --- | --- |
| 즐겨찾기 등록과 중복 등록 | [201](captures/postman-favorite-created.png), [409 FAVORITE409_1](captures/postman-favorite-duplicate.png) |
| 내 즐겨찾기 조회 | [200 · 최신 등록 순서](captures/postman-favorite-list.png) |
| 즐겨찾기 여부 조회 | [등록 전 false](captures/postman-status-false.png), [등록 후 true](captures/postman-status-true.png) |
| 즐겨찾기 해제 | [200 · result null](captures/postman-favorite-deleted.png) |
| 영화 기록 저장 | [201 · rating과 favorite](captures/postman-record-created.png) |
| 즐겨찾기 실패와 평점 롤백 | [409 FAVORITE409_1](captures/postman-record-rollback.png), [MySQL 행 수](mysql-results.txt) |
| 영화 기록 트랜잭션 | [코드 캡처](captures/movie-record-transaction.png) |
| Swagger | [API 목록](captures/swagger-endpoints.png), [영화 기록 요청·응답 예시](captures/swagger-movie-record.png) |
| Postman 컬렉션 | [29개 요청, 단언 71개 통과](postman-results.txt), [실행 파일](week08.postman_collection.json) |

영화 155를 즐겨찾기한 회원으로 `addToFavorites: true`인 영화 기록 요청을 보냈다. 평점 저장 뒤 즐겨찾기 중복으로 409가 반환됐다. MySQL에서 같은 회원과 영화의 행을 조회하니 `rating`은 0행, `favorite`는 기존 1행이었다. 평점과 즐겨찾기를 함께 요청했으므로 두 저장을 같은 트랜잭션으로 묶어, 두 번째 저장이 실패해도 평점만 남지 않게 했다.
