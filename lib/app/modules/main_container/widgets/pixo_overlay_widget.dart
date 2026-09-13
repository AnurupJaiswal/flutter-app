import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

enum PixoState { normal, minimized, hidden }

class PixoOverlayWidget extends StatefulWidget {
  const PixoOverlayWidget({super.key});

  @override
  State<PixoOverlayWidget> createState() => _PixoOverlayWidgetState();
}

class _PixoOverlayWidgetState extends State<PixoOverlayWidget>
    with TickerProviderStateMixin {
  PixoState _state = PixoState.normal;
  Offset _position = const Offset(20, 100);
  bool _isDragging = false;

  late final AnimationController _pulseController;
  late final AnimationController _entranceController;
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    // Slow breathing glow while idle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Pop-in on first build
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    // Slow rotating sparkle ring
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _openChat() {
    Get.toNamed(Routes.CHAT_HOME);
  }

  void _openVoiceDialog() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _VoiceSheet(onDone: () => CW.dismissBottomSheet(sheetContext)),
    );
  }

  void _snapToNearestEdge(Size screenSize) {
    // Snap horizontally to whichever side is closer, spring-like via AnimatedPositioned
    final screenWidth = screenSize.width;
    final currentRight = _position.dx;
    final isCloserToLeft = currentRight > screenWidth / 2 - 38;

    setState(() {
      _position = Offset(
        isCloserToLeft ? screenWidth - 96 : 10,
        _position.dy,
      );
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.sizeOf(context);

    double rightPos;
    double bottomPos;
    if (_state == PixoState.hidden) {
      rightPos = 0;
      bottomPos = 90;
    } else if (_state == PixoState.minimized) {
      rightPos = 12;
      bottomPos = 90;
    } else {
      rightPos = _position.dx;
      bottomPos = _position.dy;
    }

    return AnimatedPositioned(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      right: rightPos,
      bottom: bottomPos,
      child: GetBuilder<ThemeService>(
        builder: (_) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _buildForState(screenSize),
          );
        },
      ),
    );
  }

  Widget _buildForState(Size screenSize) {
    switch (_state) {
      case PixoState.hidden:
        return _buildHidden();
      case PixoState.minimized:
        return _buildMinimized();
      case PixoState.normal:
        return _buildNormal(screenSize);
    }
  }

  // ---------------- HIDDEN ----------------
  Widget _buildHidden() {
    return GestureDetector(
      key: const ValueKey('hidden'),
      onTap: () => setState(() => _state = PixoState.normal),
      child: Container(
        width: 18,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [CC.primary, CC.primary.withValues(alpha: 0.75)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: CC.primary.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 18),
      ),
    );
  }

  // ---------------- MINIMIZED ----------------
  Widget _buildMinimized() {
    return GestureDetector(
      key: const ValueKey('minimized'),
      onTap: _openChat,
      onLongPress: _openVoiceDialog,
      onDoubleTap: () => setState(() => _state = PixoState.normal),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: CC.surface.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CC.primary.withValues(alpha: 0.25), width: 1),
              boxShadow: [
                BoxShadow(
                  color: CC.primary.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [CC.primary, CC.primary.withValues(alpha: 0.6)],
                  ).createShader(bounds),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15),
                ),
                6.width,
                Text(
                  "Pixo",
                  style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- NORMAL (main bubble) ----------------
  Widget _buildNormal(Size screenSize) {
    return GestureDetector(
      key: const ValueKey('normal'),
      onPanStart: (_) => setState(() => _isDragging = true),
      onPanUpdate: (details) {
        setState(() {
          _position = Offset(
            (_position.dx - details.delta.dx).clamp(10.0, screenSize.width - 96),
            (_position.dy - details.delta.dy).clamp(80.0, 500.0),
          );
        });
      },
      onPanEnd: (_) => _snapToNearestEdge(screenSize),
      onTap: _openChat,
      onLongPress: _openVoiceDialog,
      child: AnimatedScale(
        scale: _isDragging ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutBack,
          ),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final glow = 0.25 + (_pulseController.value * 0.25);
              return Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    transform: GradientRotation(_rotationController.value * 6.28319),
                    colors: [
                      CC.primary,
                      CC.primary.withValues(alpha: 0.2),
                      CC.primary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CC.primary.withValues(alpha: glow),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CC.surface.withValues(alpha: 0.95),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            CC.tealSubtle,
                            CC.primary.withValues(alpha: 0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(Icons.auto_awesome_rounded, color: CC.primary, size: 24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- Extracted voice sheet (with mic pulse) ----------------
class _VoiceSheet extends StatefulWidget {
  final VoidCallback onDone;
  const _VoiceSheet({required this.onDone});

  @override
  State<_VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends State<_VoiceSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: CC.stroke, width: 0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: CC.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          20.height,
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 1.0 + (_controller.value * 0.15);
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CC.primary.withValues(alpha: 0.12 * (1 - _controller.value * 0.5)),
                      ),
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [CC.tealSubtle, CC.primary.withValues(alpha: 0.15)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: CC.primary.withValues(alpha: 0.3), width: 0.8),
                    ),
                    child: Icon(Icons.mic_rounded, color: CC.primary, size: 36),
                  ),
                ],
              );
            },
          ),
          16.height,
          Text("Pixo Voice Assistant", style: TS.titleMedium(color: CC.textPrimary)),
          8.height,
          Text(
            "Listening... Ask Pixo about your YouTube or Instagram strategy.",
            textAlign: TextAlign.center,
            style: TS.bodySmall(color: CC.textSecondary),
          ),
          24.height,
          CW.commonBtn(
            title: "Done Listening",
            width: 140,
            onTap: widget.onDone,
          ),
        ],
      ),
    );
  }
}