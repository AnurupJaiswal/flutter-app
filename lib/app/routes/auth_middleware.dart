import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/networking/api_service.dart';

/// Prevents unauthenticated users from accessing protected screens.
/// If user is NOT authenticated, redirect them to the Welcome/Landing screen.
class AuthGuardMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!ApiService.isAuthenticated) {
      return const RouteSettings(name: Routes.WELCOME);
    }
    return null;
  }
}

/// Prevents authenticated users from seeing guest-only screens (e.g., Welcome, Sign-In).
/// If user is already authenticated, redirect them into the main application.
class GuestGuardMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (ApiService.isAuthenticated) {
      return const RouteSettings(name: Routes.MAIN_CONTAINER);
    }
    return null;
  }
}
