import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:lala_ai/networking/api_service.dart';

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    try {
      // 1. Request permission for iOS (Android 13+ also requests permission here)
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      // Enable iOS foreground presentation options (alert, badge, sound)
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: false,
        sound: true,
      );

      // 2. Setup Background Message Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. On iOS, wait for APNs token before requesting FCM token
      if (!kIsWeb && Platform.isIOS) {
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          debugPrint("Waiting for iOS APNs token...");
          for (int i = 0; i < 5 && apnsToken == null; i++) {
            await Future.delayed(const Duration(seconds: 1));
            apnsToken = await _fcm.getAPNSToken();
          }
        }
        debugPrint("APNs token: $apnsToken");
      }

      // 4. Get the token (Send this to your backend)
      String? token;
      try {
        token = await _fcm.getToken();
      } catch (e) {
        debugPrint("Failed to get FCM token: $e");
      }
      
      debugPrint("\n=======================================================");
      debugPrint("🔥 [FIREBASE FCM TOKEN] 🔥");
      debugPrint(token);
      debugPrint("=======================================================\n");

      Future<void> sendTokenToBackend(String t) async {
        try {
          String platformStr = kIsWeb ? "web" : (Platform.isIOS ? "ios" : "android");
          await ApiService.post(
            '/api/v1/notifications/devices',
            body: {
              "token": t,
              "platform": platformStr,
            },
          );
          debugPrint("✅ Token successfully registered with backend.");
        } catch (e) {
          debugPrint("❌ Failed to register token with backend: $e");
        }
      }

      if (token != null) {
        await sendTokenToBackend(token);
      }
      
      // Optionally listen to token refreshes
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint("\n=======================================================");
        debugPrint("🔥 [FCM TOKEN REFRESHED] 🔥");
        debugPrint(newToken);
        debugPrint("=======================================================\n");
        sendTokenToBackend(newToken);
      });

      // 4. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('Message also contained a notification: ${message.notification?.title}');
          // You can show a local notification here if needed
        }
      });

      // 5. Handle when the app is opened from a notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('A new onMessageOpenedApp event was published!');
        // Navigate based on message.data if needed
      });
      
      // Handle app opened from terminated state via notification
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App opened from terminated state via notification');
        // Handle navigation based on initialMessage.data
      }

    } catch (e) {
      debugPrint("Failed to initialize PushNotificationService: $e");
    }
  }
}
