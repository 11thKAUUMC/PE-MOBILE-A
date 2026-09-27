import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();      // _nicknameController: 사용자가 입력한 닉네임을 화면이 살아 있는 동안 유지함  
    super.dispose();                    // dispose(): 화면이 없어질 때 Controller를 정리함
  }

  String? _validateNickname(String? value) {          // _validateNickname: 문제가 없으면 null, 문제가 있으면 오류 문구를 반환함
    final nickname = value?.trim() ?? '';

    if (nickname.isEmpty) {
      return '닉네임을 입력해주세요.';
    }

    if (nickname.length < 2) {
      return '닉네임은 두 글자 이상 입력 해주세요.';
    }

    return null; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: LayoutBuilder(                             // LayoutBuilder → ConstrainedBox: 화면이 넓어도 폼이 지나치게 넓어지지 않게함
          builder: (context, constraints) {
            final maxFormWidth =
                constraints.maxWidth >= 700 ? 560.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFormWidth),
                child: SingleChildScrollView(                           // SingleChildScrollView: 키보드가 올라오거나 화면 높이가 부족해도 스크롤되게함
                  padding: const EdgeInsets.all(24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'MovieLog와 함께\n영화를 기록해 보세요',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 32),

                        TextFormField(                          // TextFormField: validator를 쓸 수 있는 입력창. 일반 TextField와의 핵심 차이. Form과 함께 사용되어 입력값 검증을 쉽게 할 수 있음.
                          controller: _nicknameController,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: '닉네임',
                            hintText: '2자 이상 입력해 주세요',
                          ),
                          validator: _validateNickname,
                          onChanged: (_) {
                            setState(() {});                  // setState(() {}): 입력할 때마다 화면을 다시 그려, 이후 가입 버튼 활성화 조건을 추가할 기반을 만듬
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}