import 'package:lala_ai/Models/chat_model.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_response.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthRepository {
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  });

  Future<ApiResponse<UserModel>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<bool> restoreSession();

  Future<void> logout();
}

/// Production API Implementation
class ApiAuthRepository implements AuthRepository {
  @override
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.login,
      body: {
        'email': email.trim(),
        'password': password,
      },
    );

    if (response.isSuccess && response.data != null) {
      final user = UserModel.fromJson(response.data);
      await _persistSession(user);
      return ApiResponse.success(data: user, message: response.message);
    }
    return ApiResponse.error(message: response.message, statusCode: response.statusCode);
  }

  @override
  Future<ApiResponse<UserModel>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.register,
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      },
    );

    if (response.isSuccess && response.data != null) {
      final user = UserModel.fromJson(response.data);
      await _persistSession(user);
      return ApiResponse.success(data: user, message: response.message);
    }
    return ApiResponse.error(message: response.message, statusCode: response.statusCode);
  }

  @override
  Future<bool> restoreSession() async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString('accessToken');
    if (token != null && token.isNotEmpty) {
      ApiService.token = token;
      ApiService.refreshToken = pref.getString('refreshToken');
      ApiService.userUuid = pref.getString('userUuid');
      ApiService.userEmail = pref.getString('userEmail');
      ApiService.userName = pref.getString('userName');
      return true;
    }
    return false;
  }

  @override
  Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
    ApiService.token = null;
    ApiService.refreshToken = null;
    ApiService.userUuid = null;
    ApiService.userEmail = null;
    ApiService.userName = null;
  }

  Future<void> _persistSession(UserModel user) async {
    final pref = await SharedPreferences.getInstance();
    if (user.token != null) {
      await pref.setString('accessToken', user.token!);
      ApiService.token = user.token;
    }
    await pref.setString('userUuid', user.id);
    await pref.setString('userEmail', user.email);
    await pref.setString('userName', user.name);

    ApiService.userUuid = user.id;
    ApiService.userEmail = user.email;
    ApiService.userName = user.name;
  }
}

/// Mock Implementation for Practice / Testing
class MockAuthRepository implements AuthRepository {
  @override
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (email.isEmpty || !email.contains('@')) {
      return ApiResponse.error(message: "Please enter a valid email address.", statusCode: 400);
    }
    if (password.length < 6) {
      return ApiResponse.error(message: "Password must be at least 6 characters.", statusCode: 400);
    }

    final user = UserModel(
      id: "usr_lala_prod_01",
      name: email.split('@').first.replaceFirst(
            email[0],
            email[0].toUpperCase(),
          ),
      email: email,
      token: "jwt_mock_lala_token_${DateTime.now().millisecondsSinceEpoch}",
      refreshToken: "jwt_mock_lala_refresh_token",
    );

    final pref = await SharedPreferences.getInstance();
    await pref.setString('accessToken', user.token!);
    await pref.setString('refreshToken', user.refreshToken!);
    await pref.setString('userUuid', user.id);
    await pref.setString('userEmail', user.email);
    await pref.setString('userName', user.name);

    ApiService.token = user.token;
    ApiService.refreshToken = user.refreshToken;
    ApiService.userUuid = user.id;
    ApiService.userEmail = user.email;
    ApiService.userName = user.name;

    return ApiResponse.success(data: user, message: "Signed in successfully");
  }

  @override
  Future<ApiResponse<UserModel>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final user = UserModel(
      id: "usr_lala_prod_${DateTime.now().millisecondsSinceEpoch}",
      name: name.trim(),
      email: email.trim(),
      token: "jwt_mock_lala_token_${DateTime.now().millisecondsSinceEpoch}",
      refreshToken: "jwt_mock_lala_refresh_token",
    );

    final pref = await SharedPreferences.getInstance();
    await pref.setString('accessToken', user.token!);
    await pref.setString('refreshToken', user.refreshToken!);
    await pref.setString('userUuid', user.id);
    await pref.setString('userEmail', user.email);
    await pref.setString('userName', user.name);

    ApiService.token = user.token;
    ApiService.refreshToken = user.refreshToken;
    ApiService.userUuid = user.id;
    ApiService.userEmail = user.email;
    ApiService.userName = user.name;

    return ApiResponse.success(data: user, message: "Account created successfully");
  }

  @override
  Future<bool> restoreSession() async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString('accessToken');
    if (token != null && token.isNotEmpty) {
      ApiService.token = token;
      ApiService.refreshToken = pref.getString('refreshToken');
      ApiService.userUuid = pref.getString('userUuid');
      ApiService.userEmail = pref.getString('userEmail');
      ApiService.userName = pref.getString('userName');
      return true;
    }
    return false;
  }

  @override
  Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
    ApiService.token = null;
    ApiService.refreshToken = null;
    ApiService.userUuid = null;
    ApiService.userEmail = null;
    ApiService.userName = null;
  }
}
