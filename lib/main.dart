import 'package:flutter/material.dart';

import 'movie_log_app.dart';      // movie_log_app.dart 파일에 존재하는 MovieLogApp 클래스를 사용하겠음을 나타냄

void main() {
  runApp(const MovieLogApp());    // MovieLogApp이 Flutter 위젯 트리의 최상위(root) 위젯이 됨
}                                 // MovieLogApp은 MaterialApp을 반환해 앱의 기본 설정(테마, 제목, 첫 화면)을 맡는다
                                  // runApp(const MovieLogApp())을 호출하면 최상위 위젯인 MovieLogApp을 그리기 위해 MovieLogApp.build() 호출된다.
