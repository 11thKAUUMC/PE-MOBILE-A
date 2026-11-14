import 'package:flutter/foundation.dart';

class LearningMemberSession extends ChangeNotifier {
  int? _memberId;
  int? get memberId => _memberId;

  void setMemberId(int id) {
    _memberId = id;
    notifyListeners();
  }
}
