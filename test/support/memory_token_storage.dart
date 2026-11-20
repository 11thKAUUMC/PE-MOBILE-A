import 'package:movielog/data/session/token_storage.dart';

class MemoryTokenStorage implements TokenStorage {
  MemoryTokenStorage([this.token]);

  String? token;
  int deletions = 0;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String value) async => token = value;

  @override
  Future<void> delete() async {
    deletions++;
    token = null;
  }
}
