import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _userSubscription;

  AuthProvider() {
    _user = _auth.currentUser;
    _userSubscription = _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get adminName {
    if (_user == null) return 'Guest';
    if (_user!.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!;
    }
    if (_user!.email != null && _user!.email!.isNotEmpty) {
      final parts = _user!.email!.split('@');
      return parts[0].toUpperCase();
    }
    return 'Organizer';
  }

  String get adminEmail => _user?.email ?? '';

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Format input email or username automatically
  static String formatEmail(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;
    if (!trimmed.contains('@')) {
      return '$trimmed@onam.org';
    }
    return trimmed;
  }

  Future<bool> login(String rawEmail, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final email = formatEmail(rawEmail);

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String rawEmail, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final email = formatEmail(rawEmail);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  String _getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'email-already-in-use':
        return 'An account already exists with this email/username.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is disabled in Firebase Console. Please enable it in Firebase Console > Authentication > Sign-in method.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication failed. (Code: ${e.code})';
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
