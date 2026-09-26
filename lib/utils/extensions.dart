import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';

extension ColorOpacity on Color {
  Color withOpacityValue(double value) {
    return withValues(alpha: value);
  }
}

extension StringExtension on String {
  String get displayText {
    if (isEmpty) return this;
    return toLowerCase().replaceFirst(
      toLowerCase()[0],
      toLowerCase()[0].toUpperCase(),
    );
  }

  String get formatDate {
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(this));
    } catch (e) {
      return this;
    }
  }

  String get formatDateTimeFriendly {
    try {
      final dt = DateTime.parse(this).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60 && diff.inSeconds >= 0) {
        return "just now";
      } else if (diff.inMinutes < 60 && diff.inMinutes > 0) {
        return "${diff.inMinutes}m ago";
      } else if (diff.inHours < 24 && dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return DateFormat('h:mm a').format(dt);
      } else if (dt.year == now.year) {
        return DateFormat('MMM d, h:mm a').format(dt);
      } else {
        return DateFormat('MMM d, yyyy').format(dt);
      }
    } catch (e) {
      return this;
    }
  }

  String get formatSyncDate {
    try {
      final dt = DateTime.parse(this).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.abs().inSeconds < 60) {
        return "just now";
      } else if (diff.inMinutes < 60 && diff.inMinutes > 0) {
        return "${diff.inMinutes}m ago";
      } else if (diff.abs().inHours < 24 && dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return "today at ${DateFormat('h:mm a').format(dt)}";
      } else if (dt.year == now.year) {
        return DateFormat('MMM d, h:mm a').format(dt);
      } else {
        return DateFormat('MMM d, yyyy').format(dt);
      }
    } catch (e) {
      return this;
    }
  }
}

extension CommonShadow on BoxDecoration {
  BoxDecoration commonShadow({Color? shadowColor}) {
    return copyWith(
      boxShadow: [
        BoxShadow(
          color: shadowColor ?? (CC.isDark ? CC.black.withOpacityValue(0.45) : CC.black.withOpacityValue(0.08)),
          offset: const Offset(0, 6),
          blurRadius: 14,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: shadowColor?.withOpacityValue(0.5) ?? (CC.isDark ? CC.black.withOpacityValue(0.25) : CC.black.withOpacityValue(0.04)),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ],
    );
  }

  BoxDecoration glowShadow({Color? glowColor}) {
    return copyWith(
      boxShadow: [
        BoxShadow(
          color: glowColor ?? CC.primary.withOpacityValue(0.25),
          offset: const Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ],
    );
  }
}

extension NumExtension on num {
  // SizedBox Height
  SizedBox get height => SizedBox(height: toDouble());

  // SizedBox Width
  SizedBox get width => SizedBox(width: toDouble());

  // EdgeInsets
  EdgeInsets get all => EdgeInsets.all(toDouble());

  EdgeInsets symmetric({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  // BorderRadius
  BorderRadius get circular => BorderRadius.circular(toDouble());

  // Radius
  Radius get radius => Radius.circular(toDouble());

  // Duration
  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());

  // Formatting
  String get formatK {
    if (this >= 1000000) return "${(this / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M";
    if (this >= 1000) return "${(this / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K";
    return toString();
  }

  String get formatDecimal {
    return toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }
}
