import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/views/reset_password_view.dart';
import 'package:lala_ai/app/routes/app_routes.dart';

class DeepLinkService extends GetxService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Future<DeepLinkService> init() async {
    // Check initial link if app was cold started from a deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print("Error getting initial deep link: \$e");
    }

    // Listen to incoming links while app is open
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      print("Deep link stream error: \$err");
    });

    return this;
  }

  void _handleDeepLink(Uri uri) {
    // Example: lala://auth/reset-password?token=XYZ_TOKEN
    // Or web link: https://assurance-raising.../auth/reset-password?token=XYZ_TOKEN
    
    if (uri.path.contains('/auth/reset-password')) {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        // Delay slightly to ensure GetX is fully mounted if this is a cold start
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.toNamed(Routes.RESET_PASSWORD, parameters: {'token': token});
        });
      }
    }
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
