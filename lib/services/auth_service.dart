import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final AuthApi _authApi = AuthApi();
  final ApiClient _apiClient = ApiClient();

  bool _isAuthenticated = false;
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  String get userName => _currentUser?.fullName ?? _currentUser?.email.split('@').first ?? "User";
  User? get currentUser => _currentUser;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      _apiClient.setToken(token);
      try {
        await loadUserProfile();
        _isAuthenticated = true;
      } catch (e) {
        _apiClient.clearToken();
        await prefs.remove('jwt_token');
        _isAuthenticated = false;
      }
    }
  }

  Future<void> login(String email, String password) async {
    final response = await _authApi.login(email, password);
    final token = response['access_token'];
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      
      _apiClient.setToken(token);
      await loadUserProfile();
      _isAuthenticated = true;
    } else {
      throw Exception('Invalid login response');
    }
  }

  Future<void> signup(String name, String email, String password) async {
    await _authApi.register(
      email: email,
      password: password,
      fullName: name,
    );
    // Purposefully not logging the user in here to force sign in flow
  }

  Future<void> loadUserProfile() async {
    final data = await _authApi.getMe();
    _currentUser = User.fromJson(data);
  }

  Future<void> updateName(String newName) async {
    final data = await _authApi.updateProfile(fullName: newName);
    _currentUser = User.fromJson(data);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _authApi.changePassword(currentPassword, newPassword);
  }

  Future<void> deleteAccount() async {
    await _authApi.deleteAccount();
    await logout();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _apiClient.clearToken();
    _isAuthenticated = false;
    _currentUser = null;
  }
}

