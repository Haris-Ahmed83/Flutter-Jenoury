import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AppUser? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  // Getters
  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await _authService.isLoggedIn;
      if (_isLoggedIn) {
        _user = await _authService.getCurrentUser();
      }
    } catch (_) {
      _isLoggedIn = false;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(
        email: email,
        password: password,
      );
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(
      fullName: fullName,
      phone: phone,
    );

    await _authService.updateProfile(updatedUser);
    _user = updatedUser;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
