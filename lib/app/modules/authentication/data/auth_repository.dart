import 'dart:convert';
import 'package:lala_ai/Models/auth_response_model.dart';
import 'package:lala_ai/Models/creator_profile_model.dart';
import 'package:lala_ai/Models/connected_accounts_model.dart';
import 'package:lala_ai/Models/subscription_model.dart';
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

  Future<ApiResponse<CreatorProfileModel>> getCreatorProfile();

  Future<ApiResponse<dynamic>> updateCreatorProfile({
    String? displayName,
    String? bio,
    String? audienceDescription,
    String? niche,
    dynamic goals,
  });

  Future<bool> restoreSession();

  Future<void> fetchAndSaveMe();

  Future<ApiResponse<String>> getPlatformAuthUrl(String platform);

  Future<ApiResponse<dynamic>> disconnectPlatform(String platform);

  Future<void> clearSession();

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
      if (authResponse.user != null || authResponse.accessToken != null) {
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
      if (authResponse.user != null || authResponse.accessToken != null) {
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
    final response = await ApiService.put(
      ApiEndpoints.changePassword,
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
  Future<ApiResponse<CreatorProfileModel>> getCreatorProfile() async {
    final response = await ApiService.get(ApiEndpoints.creatorProfile);
    if (response.isSuccess && response.data != null) {
      final payload = response.data is Map<String, dynamic> && response.data['data'] != null
          ? response.data['data']
          : response.data;
      if (payload is Map<String, dynamic>) {
        final creatorProfile = CreatorProfileModel.fromJson(payload);
        ApiService.currentCreatorProfile = creatorProfile;
        if (creatorProfile.displayName != null && creatorProfile.displayName!.trim().isNotEmpty) {
          ApiService.userName = creatorProfile.displayName!.trim();
          final pref = await SharedPreferences.getInstance();
          await pref.setString('userName', creatorProfile.displayName!.trim());
        }
        final pref = await SharedPreferences.getInstance();
        await pref.setString('creatorProfile', jsonEncode(creatorProfile.toJson()));
        return ApiResponse.success(data: creatorProfile, message: response.message);
      }
    }
    return ApiResponse.error(message: response.message, statusCode: response.statusCode);
  }

  @override
  Future<ApiResponse<dynamic>> updateCreatorProfile({
    String? displayName,
    String? bio,
    String? audienceDescription,
    String? niche,
    dynamic goals,
  }) async {
    final Map<String, dynamic> body = {};
    if (displayName != null && displayName.isNotEmpty) body['displayName'] = displayName.trim();
    if (bio != null) body['bio'] = bio.trim();
    if (audienceDescription != null && audienceDescription.isNotEmpty) body['audienceDescription'] = audienceDescription.trim();
    if (niche != null && niche.isNotEmpty) body['niche'] = niche.trim();
    if (goals != null) body['goals'] = goals;

    final response = await ApiService.put(
      ApiEndpoints.updateCreatorProfile,
      body: body,
    );

    if (response.isSuccess) {
      if (displayName != null && displayName.trim().isNotEmpty) {
        ApiService.userName = displayName.trim();
        final pref = await SharedPreferences.getInstance();
        await pref.setString('userName', displayName.trim());
      }
      // Re-fetch me and creator profile to update local user/creator caches
      await getCreatorProfile();
      await fetchAndSaveMe();
    }
    return response;
  }

  @override
  Future<void> clearSession() async {
    await ApiService.clearSessionData();
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

      final userProfileJson = pref.getString('userProfile');
      if (userProfileJson != null) {
        try {
          final userMap = jsonDecode(userProfileJson) as Map<String, dynamic>;
          ApiService.currentUser = UserModel.fromJson(userMap);
        } catch (_) {}
      }

      final subscriptionJson = pref.getString('userSubscription');
      if (subscriptionJson != null) {
        try {
          final subMap = jsonDecode(subscriptionJson) as Map<String, dynamic>;
          ApiService.currentSubscription = SubscriptionModel.fromJson(subMap);
        } catch (_) {}
      }

      final creatorProfileJson = pref.getString('creatorProfile');
      if (creatorProfileJson != null) {
        try {
          final creatorMap = jsonDecode(creatorProfileJson) as Map<String, dynamic>;
          ApiService.currentCreatorProfile = CreatorProfileModel.fromJson(creatorMap);
        } catch (_) {}
      }

      // Consistently prioritize display name for ApiService.userName
      if (ApiService.currentCreatorProfile?.displayName?.trim().isNotEmpty == true) {
        ApiService.userName = ApiService.currentCreatorProfile!.displayName!.trim();
      } else if (ApiService.currentUser?.effectiveDisplayName.isNotEmpty == true) {
        ApiService.userName = ApiService.currentUser!.effectiveDisplayName;
      }

      final accountsJson = pref.getString('connectedAccounts');
      if (accountsJson != null) {
        try {
          final accMap = jsonDecode(accountsJson) as Map<String, dynamic>;
          ApiService.currentConnectedAccounts = ConnectedAccountsModel.fromJson(accMap);
        } catch (_) {}
      }

      final statsJson = pref.getString('creatorStats');
      if (statsJson != null) {
        try {
          final statsMap = jsonDecode(statsJson) as Map<String, dynamic>;
          ApiService.currentStats = CreatorStatsModel.fromJson(statsMap);
        } catch (_) {}
      }

      return true;
    }
    // If no token exists, ensure session state is completely wiped
    await clearSession();
    return false;
  }
  
  @override
  Future<void> fetchAndSaveMe() async {
    final response = await getMe();
    if (response.isSuccess && response.data != null) {
      // Backend may return data nested in 'data' object or directly
      final payload = response.data!['data'] ?? response.data!;
      final user = payload['user'] != null ? UserModel.fromJson(payload['user']) : null;
      final subscription = payload['subscription'] != null ? SubscriptionModel.fromJson(payload['subscription']) : null;
      final creatorProfile = payload['creatorProfile'] != null ? CreatorProfileModel.fromJson(payload['creatorProfile']) : null;
      final connectedAccounts = payload['connectedAccounts'] != null
          ? ConnectedAccountsModel.fromJson(Map<String, dynamic>.from(payload['connectedAccounts']))
          : null;
      final stats = payload['stats'] != null
          ? CreatorStatsModel.fromJson(Map<String, dynamic>.from(payload['stats']))
          : null;

      final pref = await SharedPreferences.getInstance();

      final resolvedDisplayName = (creatorProfile?.displayName?.trim().isNotEmpty == true)
          ? creatorProfile!.displayName!.trim()
          : ((user?.effectiveDisplayName.trim().isNotEmpty == true)
              ? user!.effectiveDisplayName.trim()
              : (user?.name.trim().isNotEmpty == true ? user!.name.trim() : 'Creator'));

      if (user != null) {
        await pref.setString('userUuid', user.id);
        await pref.setString('userEmail', user.email);
        await pref.setString('userName', resolvedDisplayName);
        await pref.setString('userProfile', jsonEncode(user.toJson()));

        ApiService.userUuid = user.id;
        ApiService.userEmail = user.email;
        ApiService.userName = resolvedDisplayName;
        ApiService.currentUser = user;
      }

      if (subscription != null) {
        await pref.setString('userSubscription', jsonEncode(subscription.toJson()));
        ApiService.currentSubscription = subscription;
      }

      if (creatorProfile != null) {
        await pref.setString('creatorProfile', jsonEncode(creatorProfile.toJson()));
        ApiService.currentCreatorProfile = creatorProfile;
        if (creatorProfile.displayName?.trim().isNotEmpty == true) {
          ApiService.userName = creatorProfile.displayName!.trim();
          await pref.setString('userName', creatorProfile.displayName!.trim());
        }
      }

      if (connectedAccounts != null) {
        await pref.setString('connectedAccounts', jsonEncode(connectedAccounts.toJson()));
        ApiService.currentConnectedAccounts = connectedAccounts;
      }

      if (stats != null) {
        await pref.setString('creatorStats', jsonEncode(stats.toJson()));
        ApiService.currentStats = stats;
      }
    }
  }

  @override
  Future<ApiResponse<String>> getPlatformAuthUrl(String platform) async {
    final response = await ApiService.get(ApiEndpoints.platformAuthUrl(platform));
    if (response.isSuccess && response.data != null) {
      // Backend returns: {"url": "https://..."} or {"data": {"url": "https://..."}}
      final dynamic data = response.data is Map ? response.data : {};
      final url = data['url']?.toString() ??
          (data['data'] is Map ? data['data']['url']?.toString() : null);
      if (url != null && url.isNotEmpty) {
        return ApiResponse.success(data: url, message: response.message);
      }
      return ApiResponse.error(message: "Authorization URL not found in response");
    }
    return ApiResponse.error(message: response.message, statusCode: response.statusCode);
  }

  @override
  Future<ApiResponse<dynamic>> disconnectPlatform(String platform) async {
    final upperPlatform = platform.toUpperCase();
    dynamic accountId;

    // 1. Check if ID is already available from cached connected accounts (e.g. if backend dev provides id in auth/me)
    if (upperPlatform == 'YOUTUBE') {
      accountId = ApiService.currentConnectedAccounts?.youtube?.id;
    } else if (upperPlatform == 'INSTAGRAM') {
      accountId = ApiService.currentConnectedAccounts?.instagram?.id;
    } else if (upperPlatform == 'TIKTOK') {
      accountId = ApiService.currentConnectedAccounts?.tiktok?.id;
    }

    // 2. If no ID found yet, fetch from GET /api/v1/creators/me/connections
    if (accountId == null) {
      try {
        final connRes = await ApiService.get(ApiEndpoints.creatorConnections);
        if (connRes.isSuccess && connRes.data != null) {
          final dynamic raw = connRes.data is Map && connRes.data['data'] != null
              ? connRes.data['data']
              : connRes.data;

          if (raw is List) {
            for (final item in raw) {
              if (item is Map) {
                final p = (item['platform'] ?? item['provider'] ?? item['type'])
                    ?.toString()
                    .toUpperCase();
                if (p == upperPlatform) {
                  accountId = item['id'] ?? item['accountId'];
                  break;
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    // 3. Call DELETE /api/v1/creators/me/connections/accounts/{id} if found
    if (accountId != null) {
      final response = await ApiService.delete(
        ApiEndpoints.disconnectConnectionAccount(accountId),
      );
      if (response.isSuccess) {
        await fetchAndSaveMe();
      }
      return response;
    }

    // 4. Fallback to platform-based DELETE
    final fallbackRes = await ApiService.delete(ApiEndpoints.disconnectPlatform(platform));
    await fetchAndSaveMe();
    return fallbackRes;
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
    // Clear any existing session before saving a new user's credentials
    await clearSession();

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
      final preferredDisplayName = user.effectiveDisplayName;
      await pref.setString('userUuid', user.id);
      await pref.setString('userEmail', user.email);
      await pref.setString('userName', preferredDisplayName);
      await pref.setString('userProfile', jsonEncode(user.toJson()));

      ApiService.userUuid = user.id;
      ApiService.userEmail = user.email;
      ApiService.userName = preferredDisplayName;
      ApiService.currentUser = user;
    }
  }
}
