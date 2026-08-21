import 'dart:async';

/// Stub Auth Service representing communication with the backend
class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;
  String _userName = "User"; // Default fallback

  bool get isAuthenticated => _isAuthenticated;
  String get userName => _userName;

  Future<bool> login(String email, String password) async {
    // Check local mock validations
    if (email.isEmpty || password.isEmpty) return false;
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In actual implementation, fetch user info from API
    // Setting mock username based on email for visualization
    _userName = email.split('@').first;
    _isAuthenticated = true;
    return true;
  }

  Future<bool> signup(String name, String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    _userName = name.isNotEmpty ? name.split(' ').first : email.split('@').first;
    _isAuthenticated = true;
    return true;
  }

  Future<void> logout() async {
    // ApiClient().clearToken();
    _isAuthenticated = false;
    _userName = "User";
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
