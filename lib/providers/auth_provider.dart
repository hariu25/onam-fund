import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = true; // Auto logged-in for smooth demo experience
  String _adminName = 'Onam Organizer';
  String _adminEmail = 'admin@onam.org';

  bool get isLoggedIn => _isLoggedIn;
  String get adminName => _adminName;
  String get adminEmail => _adminEmail;

  bool login(String usernameOrEmail, String password) {
    // Simple demo validation
    if (usernameOrEmail.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      _adminEmail = usernameOrEmail.contains('@') ? usernameOrEmail : '$usernameOrEmail@onam.org';
      _adminName = usernameOrEmail.split('@')[0].toUpperCase();
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
