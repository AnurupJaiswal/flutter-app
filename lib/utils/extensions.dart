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
}

extension CommonShadow on BoxDecoration {
  BoxDecoration commonShadow({Color? shadowColor}) {
    return copyWith(
      boxShadow: [
        BoxShadow(
          color: shadowColor ?? CC.border.withOpacityValue(0.4),
          offset: const Offset(0, 2),
          blurRadius: 8,
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
}
