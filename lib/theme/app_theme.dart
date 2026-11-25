import 'package:flutter/material.dart';

import 'app_color.dart';

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.light(
    primary: AppColor.primaryPurple,
    onPrimary: AppColor.surfaceWhite,
    primaryContainer: AppColor.primaryContainer,
    onPrimaryContainer: AppColor.primaryPurple,
    secondary: AppColor.textSecondary,
    onSecondary: AppColor.surfaceWhite,
    error: AppColor.destructive,
    onError: AppColor.surfaceWhite,
    surface: AppColor.surfaceWhite,
    onSurface: AppColor.textPrimary,
    outline: AppColor.borderSlate,
  );
  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.control),
    borderSide: const BorderSide(color: AppColor.borderSlate),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColor.canvasBg,
    dividerColor: AppColor.borderSlate,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColor.textPrimary),
      bodyMedium: TextStyle(color: AppColor.textPrimary),
      bodySmall: TextStyle(color: AppColor.textSecondary),
      titleLarge: TextStyle(
        color: AppColor.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppColor.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.canvasBg,
      foregroundColor: AppColor.textPrimary,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColor.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColor.surfaceWhite,
      elevation: 1,
      shadowColor: const Color(0x0A0F172A),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColor.borderSlate),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColor.canvasBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColor.primaryPurple, width: 1.5),
      ),
      errorBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColor.destructive),
      ),
      focusedErrorBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColor.destructive, width: 1.5),
      ),
      labelStyle: const TextStyle(
        color: AppColor.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(color: AppColor.textSecondary, fontSize: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColor.borderSlate;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColor.primaryPressed;
            }
            return AppColor.primaryPurple;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? AppColor.disabled
              : AppColor.surfaceWhite,
        ),
        minimumSize: const WidgetStatePropertyAll(Size(140, 50)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColor.primaryPurple,
        disabledForegroundColor: AppColor.disabled,
        minimumSize: const Size(140, 50),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: const BorderSide(color: AppColor.primaryPurple),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColor.textSecondary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColor.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColor.textPrimary,
      contentTextStyle: TextStyle(color: AppColor.surfaceWhite),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColor.primaryPurple,
      linearTrackColor: AppColor.primaryContainer,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColor.surfaceWhite,
      indicatorColor: AppColor.primaryContainer,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? AppColor.primaryPurple
              : const Color(0xFF64748B),
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
          fontSize: 12,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColor.primaryPurple
              : const Color(0xFF64748B),
        ),
      ),
    ),
  );
}
