import 'package:lala_ai/Models/auth_response_model.dart';
import 'package:lala_ai/Models/user_model.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_response.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthRepository {
  Future<ApiResponse<AuthResponseModel>> login({
    required String email,
    required String password,
  });

  Future<ApiResponse<AuthResponseModel>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<ApiResponse<dynamic>> requestMagicLink(String email);

  Future<ApiResponse<AuthResponseModel>> verifyMagicLink(String token);

  Future<ApiResponse<dynamic>> sendOtp(String email);

  Future<ApiResponse<AuthResponseModel>> verifyOtp(String email, String otp);

  Future<ApiResponse<UserModel>> completeSetup({
    required String fullName,
    required String displayName,
    required String niche,
    String? goals,
    String? password,
  });

  Future<ApiResponse<Map<String, dynamic>>> getMe();

  Future<ApiResponse<dynamic>> forgotPassword(String email);

  Future<ApiResponse<dynamic>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<ApiResponse<dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<ApiResponse<dynamic>> createHandoff();

  Future<ApiResponse<AuthResponseModel>> exchangeHandoff(String code);

  Future<bool> restoreSession();

  Future<void> fetchAndSaveMe();

  Future<void> logout();
}

/// Production API Implementation
class ApiAuthRepository implements AuthRepository {
  @override
  Future<ApiResponse<AuthResponseModel>> login({
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
      final authResponse = AuthResponseModel.fromJson(response.data);
      if (authResponse.user != null) {
        await _persistSession(authResponse);
      }
      return ApiResponse.success(data: authResponse, message: response.message);
    }
    return ApiResponse.error(message: response.message, statusCode: response.statusCode);
  }

  @override
  Future<ApiResponse<AuthResponseModel>> register({
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
      final authResponse = AuthResponseModel.fromJson(response.data);
      if (authResponse.user != null) {
        await _persistSession(authResponse);
      }
      return ApiResponse.success(data: authResponse, message: response.message);
    }
    return ApiResponse.error(message: response.message, statusCode: response.statusCode);
  }

  @override
  Future<ApiResponse<dynamic>> requestMagicLink(String email) async {
    final response = await ApiService.post(
      ApiEndpoints.magicLinkRequest,
      body: {'email': email.trim(), 'client': 'mobile'},
    );
    return response;
  }

  @override
  Future<ApiResponse<AuthResponseModel>> verifyMagicLink(String token) async {
    final response = await ApiService.post(
      ApiEndpoints.magicLinkVerify,
      body: {'token': token.trim()},
    );

    if (response.isSuccess && response.data != null) {
      final authResponse = AuthResponseModel.fromJson(response.data);
      if (authResponse.user != null) {
        await _persistSession(authResponse);
      }
      return ApiResponse.success(data: authResponse, message: response.message);
    }
    return ApiResponse.error(message: response.message, statusCode: response.statusCode);
  }

  @override
  Future<ApiResponse<dynamic>> sendOtp(String email) async {
    final response = await ApiService.post(
      ApiEndpoints.sendEmailOtp,
      body: {'email': email.trim(), 'client': 'MOBILE'},
    );
    return response;
  }

  @override
  Future<ApiResponse<AuthResponseModel>> verifyOtp(String email, String otp) async {
    final response = await ApiService.post(
      ApiEndpoints.verifyEmailOtp,
      body: {'email': email.trim(), 'otp': otp.trim()},
    );

    if (response.isSuccess && response.data != null) {
      final authResponse = AuthResponseModel.fromJson(response.data);
      if (authResponse.user != null) {
        await _persistSession(authResponse);
      }
      return ApiResponse.success(data: authResponse, message: response.message);
    }
    return ApiResponse.error(message: response.message, statusCode: response.statusCode);
  }

  @override
  Future<ApiResponse<UserModel>> completeSetup({
    required String fullName,
    required String displayName,
    required String niche,
    String? goals,
    String? password,
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.completeSetup,
      body: {
        'fullName': fullName.trim(),
        'displayName': displayName.trim(),
        'niche': niche.trim(),
        'goals': goals?.trim(),
        'password': password,
        'termsAccepted': true,
      },
    );

    if (response.isSuccess && response.data != null) {
      final user = UserModel.fromJson(response.data);
      // Retain existing tokens when setup completes
      final updatedUser = user.copyWith(
        token: ApiService.token,
        refreshToken: ApiService.refreshToken,
      );
      await _persistSession(AuthResponseModel(
        success: true,
        accessToken: ApiService.token,
        refreshToken: ApiService.refreshToken,
        user: updatedUser,
      ));
      return ApiResponse.success(data: updatedUser, message: response.message);
    }
    return ApiResponse.error(message: response.message, statusCode: response.statusCode);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getMe() async {
    final response = await ApiService.get(ApiEndpoints.me);
    if (response.isSuccess) {
      return ApiResponse.success(data: response.data as Map<String, dynamic>?, message: response.message);
    }
    return ApiResponse.error(message: response.message, statusCode: response.statusCode);
  }

  @override
  Future<ApiResponse<dynamic>> forgotPassword(String email) async {
    final response = await ApiService.post(
      ApiEndpoints.forgotPassword,
      body: {'email': email.trim()},
    );
    return response;
  }

  @override
  Future<ApiResponse<dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.resetPassword,
      body: {
        'token': token,
        'newPassword': newPassword,
      },
    );
    return response;
  }

  @override
  Future<ApiResponse<dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Note: Assuming endpoint exists in backend based on previous implementation
    final response = await ApiService.post(
      '/api/v1/auth/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    return response;
  }

  @override
  Future<ApiResponse<dynamic>> createHandoff() async {
    final response = await ApiService.post(ApiEndpoints.mobileCreateHandoff);
    return response;
  }

  @override
  Future<ApiResponse<AuthResponseModel>> exchangeHandoff(String code) async {
    final response = await ApiService.post(
      ApiEndpoints.mobileExchangeHandoff,
      body: {'code': code.trim()},
    );

    if (response.isSuccess && response.data != null) {
      final authResponse = AuthResponseModel.fromJson(response.data);
      if (authResponse.user != null) {
        await _persistSession(authResponse);
      }
      return ApiResponse.success(data: authResponse, message: response.message);
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
  Future<void> fetchAndSaveMe() async {
    final response = await getMe();
    if (response.isSuccess && response.data != null) {
      // Backend may return data nested in 'data' object or directly
      final payload = response.data!['data'] ?? response.data!;
      final user = payload['user'] != null ? UserModel.fromJson(payload['user']) : null;
      if (user != null) {
        final pref = await SharedPreferences.getInstance();
        await pref.setString('userUuid', user.id);
        await pref.setString('userEmail', user.email);
        await pref.setString('userName', user.name);

        ApiService.userUuid = user.id;
        ApiService.userEmail = user.email;
        ApiService.userName = user.name;
      }
    }
  }

  @override
  Future<void> logout() async {
    try {
      await ApiService.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore errors during logout API call
    }
    await ApiService.logout();
  }

  Future<void> _persistSession(AuthResponseModel authResponse) async {
    final pref = await SharedPreferences.getInstance();
    final user = authResponse.user;
    
    if (authResponse.accessToken != null) {
      await pref.setString('accessToken', authResponse.accessToken!);
      ApiService.token = authResponse.accessToken;
    }
    if (authResponse.refreshToken != null) {
      await pref.setString('refreshToken', authResponse.refreshToken!);
      ApiService.refreshToken = authResponse.refreshToken;
    }
    
    if (user != null) {
      await pref.setString('userUuid', user.id);
      await pref.setString('userEmail', user.email);
      await pref.setString('userName', user.name);

      ApiService.userUuid = user.id;
      ApiService.userEmail = user.email;
      ApiService.userName = user.name;
    }
  }
}
