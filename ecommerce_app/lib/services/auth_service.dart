import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<bool> get isLoggedIn async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return AppUser.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // In production, call your authentication API here
    // final response = await http.post(
    //   Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
    //   body: json.encode({'email': email, 'password': password}),
    // );

    // Validate credentials (demo validation)
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Email and password are required');
    }

    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    // Create user from response (simulated)
    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      fullName: _extractNameFromEmail(email),
      createdAt: DateTime.now(),
    );

    await _saveUser(user);
    return user;
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // In production, call your registration API here
    if (fullName.isEmpty) {
      throw AuthException('Full name is required');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw AuthException('A valid email is required');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      fullName: fullName,
      createdAt: DateTime.now(),
    );

    await _saveUser(user);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  Future<void> updateProfile(AppUser user) async {
    await _saveUser(user);
  }

  Future<void> _saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  String _extractNameFromEmail(String email) {
    final name = email.split('@').first;
    return name
        .replaceAll(RegExp(r'[._-]'), ' ')
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
