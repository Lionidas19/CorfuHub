import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color accentTeal = Color(0xFF00897B);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningAmber = Color(0xFFF57C00);
  static const Color successGreen = Color(0xFF388E3C);

  // Issue status colours
  static const Color issueOpen = Color(0xFFD32F2F);
  static const Color issueInProgress = Color(0xFFF57C00);
  static const Color issueResolved = Color(0xFF388E3C);
  static const Color issueClosed = Color(0xFF757575);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          secondary: accentTeal,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  /// Issue status -> colour mapping.
  static Color statusColor(String? status) => switch (status) {
        'open' => issueOpen,
        'in_progress' => issueInProgress,
        'resolved' => issueResolved,
        _ => issueClosed,
      };
}
