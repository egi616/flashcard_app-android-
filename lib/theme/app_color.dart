import 'package:flutter/material.dart';

abstract final class AppColor {
  static const primaryPurple = Color(0xFF6D28D9);
  static const primaryPressed = Color(0xFF5B21B6);
  static const primaryContainer = Color(0xFFEDE9FE);
  static const cardBackLilac = Color(0xFFF5F3FF);
  static const canvasBg = Color(0xFFF8F9FC);
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const borderSlate = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const successEmerald = Color(0xFF10B981);
  static const warningAmber = Color(0xFFF59E0B);
  static const warningText = Color(0xFFB45309);
  static const destructive = Color(0xFFEF4444);

  static const primary = primaryPurple;
  static const secondary = borderSlate;
  static const tertiary = surfaceWhite;
  static const neutral = surfaceWhite;
  static const surface = surfaceWhite;
  static const onSurface = textPrimary;
  static const error = destructive;
  static const muted = textSecondary;
  static const subtleSurface = canvasBg;
  static const disabled = Color(0xFF94A3B8);
}

abstract final class AppRadius {
  static const control = 12.0;
  static const card = 16.0;
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 26.0;
  static const xl = 72.0;
}

