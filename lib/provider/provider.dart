import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;
  Session? _session;

  String? get userId => _userId;
  Session? get session => _session;

  void setUserSession(String? userId, Session? session) {
    _userId = userId;
    _session = session;
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _session = null;
    notifyListeners();
  }
}
