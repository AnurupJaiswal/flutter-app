import 'package:flutter/material.dart';

/// A reusable wrapper widget that automatically dismisses the soft keyboard
/// and clears focus from any active [TextField] or [TextFormField] when the user
/// taps outside focused input fields anywhere on the screen.
class KeyboardDismissWrapper extends StatelessWidget {
  /// The child widget tree (e.g., Scaffold, Screen, or App Builder).
  final Widget child;

  /// Optional custom callback executed when the user taps outside.
  final VoidCallback? onDismiss;

  const KeyboardDismissWrapper({
    super.key,
    required this.child,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        dismissKeyboard();
        onDismiss?.call();
      },
      child: child,
    );
  }

  /// Utility method to programmatically dismiss the keyboard using Flutter's focus system.
  static void dismissKeyboard() {
    final currentFocus = FocusManager.instance.primaryFocus;
    if (currentFocus != null && currentFocus.hasFocus) {
      currentFocus.unfocus();
    }
  }
}
