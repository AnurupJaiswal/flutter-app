import 'package:get/get.dart';

class WelcomeBinding extends Bindings {
  @override
  void dependencies() {
    // No controller dependency — the Welcome screen is a pure UI screen.
    // Navigation to AuthenticationView will lazily initialize AuthController
    // via the existing AuthBinding when the route is pushed.
  }
}
