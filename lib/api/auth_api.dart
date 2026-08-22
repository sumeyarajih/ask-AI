import 'api_client.dart';

class AuthApi {
  final ApiClient _client = ApiClient();

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final data = {
      'email': email,
      'password': password,
      if (fullName != null) 'full_name': fullName,
    };
    return await _client.post('/auth/register', data: data);
  }

  /// Login and receive a JWT token
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = {
      'email': email,
      'password': password,
    };
    return await _client.post('/auth/login', data: data);
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getMe() async {
    return await _client.get('/auth/me');
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({String? fullName}) async {
    final data = {
      if (fullName != null) 'full_name': fullName,
    };
    return await _client.put('/auth/me', data: data);
  }

  /// Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final data = {
      'current_password': currentPassword,
      'new_password': newPassword,
    };
    await _client.put('/auth/me/password', data: data);
  }

  /// Request password reset link
  Future<void> forgotPassword(String email) async {
    final data = {'email': email};
    await _client.post('/auth/forgot-password', data: data);
  }

  /// Delete account globally
  Future<void> deleteAccount() async {
    await _client.delete('/auth/delete-account');
  }
}
