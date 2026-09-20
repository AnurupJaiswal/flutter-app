# Refresh Token Management & Authentication Lifecycle

This document explains how **Access Tokens** and **Refresh Tokens** are managed, stored, intercepted, and refreshed across the Lala AI Flutter application.

---

## 1. Architecture Overview

The application utilizes a standard **Dual-Token Authentication Architecture**:
- **Access Token (`accessToken`)**: Short-lived JWT used in the `Authorization: Bearer <token>` header for all authenticated backend requests.
- **Refresh Token (`refreshToken`)**: Long-lived token used solely to request a new `accessToken` when the current one expires.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           STORAGE LAYERS                                │
├───────────────────────────────────┬─────────────────────────────────────┤
│        In-Memory (Fast)           │     Persistent (Device Storage)     │
├───────────────────────────────────┼─────────────────────────────────────┤
│  • ApiService.token               │  • SharedPreferences('accessToken') │
│  • ApiService.refreshToken        │  • SharedPreferences('refreshToken')│
│  • ApiService.currentUser         │  • SharedPreferences('userProfile') │
└───────────────────────────────────┴─────────────────────────────────────┘
```

---

## 2. Authentication Lifecycle

### 2.1 Initial Login / Sign-Up / OAuth Callback
1. When user logs in via Email/Password, OTP, or OAuth (Google / Apple), the backend returns an authentication payload:
   ```json
   {
     "status": "success",
     "message": "Authentication successful",
     "data": {
       "user": { ... },
       "accessToken": "eyJhbGciOi...",
       "refreshToken": "eyJhbGciOi..."
     }
   }
   ```
2. `AuthRepository` captures the tokens and invokes `_saveSession(authResponse)`:
   - Stores `accessToken` and `refreshToken` in persistent `SharedPreferences`.
   - Populates `ApiService.token` and `ApiService.refreshToken` in memory.
   - Saves cached profile data (`UserModel`, `CreatorProfileModel`, `SubscriptionModel`).

### 2.2 App Startup / Session Restore
1. When the app initializes (`SplashController` or app startup), `AuthRepository.restoreSession()` is called.
2. It loads `accessToken` and `refreshToken` from `SharedPreferences` into `ApiService`.
3. If `accessToken` is present, `ApiService.isAuthenticated` returns `true` and the user proceeds directly to the main dashboard.

---

## 3. Automatic 401 Interception & Concurrency-Safe Refresh

The entire refresh token workflow is managed automatically at the networking layer in [`ApiService`](file:///d:/StudioProjects/lala_ai/lib/networking/api_service.dart).

```
   Client Request
        │
        ▼
   [Dio Interceptor: onRequest]  ──► Injects "Authorization: Bearer <accessToken>"
        │
        ▼
   Backend Server
        │
   ┌────┴──────────────────────────┐
   │ 200 OK                        │ 401 Unauthorized (Access token expired)
   ▼                               ▼
 Return Response            [Dio Interceptor: onError]
                                   │
                                   ├─► Is already refresh endpoint? ──► YES ──► Session Expired (Logout)
                                   ├─► Already retried? ──────────────► YES ──► Fail Request
                                   │
                                   ▼ NO
                            _attemptRefresh()
                                   │
                    ┌──────────────┴──────────────┐
                    │ Concurrency Lock Check      │
                    │ (_refreshCompleter active?) │
                    └──────────────┬──────────────┘
                        NO         │        YES
                        ▼          │         ▼
              Spawn Completer      │   Await existing Future
              POST /auth/refresh   │   (No duplicate API call)
                        │          │         │
                   ┌────┴────┐     │         │
                   │ Success │ Fail│         │
                   ▼         ▼     │         ▼
              Save Tokens  Logout  │   Receive result
                   │               │         │
                   └───────────────┼─────────┘
                                   │
                                   ▼
                         [Retry Original Request]
                         with new Bearer token
```

### 3.1 Concurrency Lock via `Completer<bool>`
If the user's access token expires while multiple asynchronous API requests are in flight (e.g. Dashboard loading user stats, audits, and connections simultaneously):
- **Problem**: 3 to 5 simultaneous requests might receive a `401 Unauthorized` at the exact same millisecond. Making 5 simultaneous refresh token calls causes race conditions and token invalidation on the backend.
- **Solution in `ApiService._attemptRefresh()`**:
  ```dart
  static Completer<bool>? _refreshCompleter;

  static Future<bool> _attemptRefresh() async {
    if (_refreshCompleter != null) {
      // Refresh already running, await active refresh future
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      if (refreshToken == null || refreshToken!.trim().isEmpty) {
        completer.complete(false);
        return false;
      }

      // Independent Dio instance (avoids circular interceptor loop)
      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiEndpoints.baseUrl.trim(),
        connectTimeout: const Duration(seconds: 15),
      ));

      final response = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic raw = response.data;
        final data = raw is Map && raw['data'] != null ? raw['data'] : raw;
        final newToken = data['accessToken'] ?? data['token'];
        final newRefresh = data['refreshToken'];

        if (newToken != null && newToken.toString().trim().isNotEmpty) {
          token = newToken.toString().trim();
          if (newRefresh != null && newRefresh.toString().trim().isNotEmpty) {
            refreshToken = newRefresh.toString().trim();
          }

          final pref = await _getPrefs;
          await pref.setString('accessToken', token!);
          if (refreshToken != null) {
            await pref.setString('refreshToken', refreshToken!);
          }

          completer.complete(true);
          return true;
        }
      }
      completer.complete(false);
    } catch (e) {
      completer.complete(false);
    } finally {
      _refreshCompleter = null;
    }
    return false;
  }
  ```

### 3.2 Transparent Request Retry
When `_attemptRefresh()` returns `true`:
1. The failed request's options are updated:
   - `requestOptions.headers['Authorization'] = 'Bearer $token';`
   - `requestOptions.extra['isRetry'] = true;`
2. The original request is re-executed via `dio.request(...)`.
3. The calling UI or Controller receives the successful result as if no expiration occurred.

---

## 4. Session Expiration & Logout Handling

When the refresh token itself is expired, invalid, or revoked:
1. `_attemptRefresh()` returns `false` (or the `/auth/refresh` request returns `401`).
2. `_handleSessionExpired()` is executed:
   ```dart
   static void _handleSessionExpired() {
     if (_sessionExpiredHandled) return;
     _sessionExpiredHandled = true;
     CM.showToast("Your session has expired. Please sign in again.", isError: true);
     logout();
   }
   ```
3. `ApiService.clearSessionData()` purges all credentials:
   - In-memory static variables reset to `null`.
   - `SharedPreferences` keys (`accessToken`, `refreshToken`, `userProfile`, `creatorProfile`, etc.) removed.
4. `ApiService.clearUserControllers()` removes transient GetX controllers to prevent cross-account state leakage.
5. `AppNavigationService.navigateToSignIn()` redirects the user to the Login screen.

---

## 5. Backend Alignment Issue: HTTP 400 Returned for Auth Failures

> [!WARNING]
> **Issue to Share with Backend Team**: Some backend endpoints return `HTTP 400 Bad Request` with an authentication error message (e.g. `"Authentication required"`, `"Authorization is required"`, or `"Invalid token"`) instead of the standard `HTTP 401 Unauthorized`.

### 5.1 Why This Is Problematic
- **Standard REST/HTTP Specification**:
  - `HTTP 401 Unauthorized`: Specifically indicates missing, invalid, or expired credentials. Triggers the client's automated token refresh mechanism.
  - `HTTP 400 Bad Request`: Indicates malformed payload, missing query parameters, or validation failures.
- **Client Impact**:
  - Standard HTTP interceptors (Dio, Axios, Retrofit) monitor `HTTP 401` to trigger silent refresh (`POST /api/v1/auth/refresh`) and seamlessly retry requests without interrupting the user.
  - When the backend returns `HTTP 400`, the mobile app cannot cleanly distinguish a client validation bug from an expired token without fragile string parsing. This leads to broken API calls or unnecessary sign-in prompts instead of transparent background token renewals.

### 5.2 Example of Observed Problematic Response
```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "status": "error",
  "message": "Authentication required",
  "data": null
}
```

### 5.3 Required Backend Fix
1. **Update Middleware / JWT Guard**: Ensure that all protected routes return `HTTP 401 Unauthorized` whenever:
   - The `Authorization` header is missing or empty.
   - The Bearer JWT is expired (`TokenExpiredError`).
   - The Bearer JWT signature is invalid or malformed.
2. **Correct Response Structure**:
   ```http
   HTTP/1.1 401 Unauthorized
   Content-Type: application/json

   {
     "status": "error",
     "message": "Access token expired or invalid",
     "code": "UNAUTHORIZED"
   }
   ```
3. **Reserve HTTP 400 Strictly for Data Validation**:
   - `HTTP 400` should only be returned when request bodies or query parameters fail schema validation (e.g., missing required fields, invalid date formats).

### 5.4 Client-Side Fallback Implemented in App
To ensure app stability while the backend fix is deployed, the mobile app's Dio interceptor in [`ApiService.dart`](file:///d:/StudioProjects/lala_ai/lib/networking/api_service.dart#L90-L110) now checks for both `HTTP 401` and `HTTP 400` containing `"authentication required"`, `"authorization required"`, `"unauthorized"`, or `"token expired"`. However, **a proper backend fix returning 401 is still required** for full RFC compliance and reliable error handling.

---

## 6. Key File Reference

| File | Purpose | Key Methods |
| :--- | :--- | :--- |
| [`lib/networking/api_service.dart`](file:///d:/StudioProjects/lala_ai/lib/networking/api_service.dart) | Core HTTP client & 401/400 auto-refresh interceptor | `_createDio()`, `_attemptRefresh()`, `_handleSessionExpired()`, `clearSessionData()` |
| [`lib/networking/api_endpoints.dart`](file:///d:/StudioProjects/lala_ai/lib/networking/api_endpoints.dart) | Endpoint definitions | `ApiEndpoints.refresh = '/api/v1/auth/refresh'` |
| [`lib/app/modules/authentication/data/auth_repository.dart`](file:///d:/StudioProjects/lala_ai/lib/app/modules/authentication/data/auth_repository.dart) | Auth business logic & session persistence | `restoreSession()`, `_saveSession()`, `logout()` |
| [`lib/Models/auth_response_model.dart`](file:///d:/StudioProjects/lala_ai/lib/Models/auth_response_model.dart) | Data transfer object for login/signup/refresh response | `AuthResponseModel.fromJson()` |

