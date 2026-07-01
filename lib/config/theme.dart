import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Vine & Branches — Design Tokens
// Extracted from the React / Tailwind source components.
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppColors {
  // ── Primary greens (Living Tree / Peer Session) ──────────────────────────
  static const Color primaryGreen = Color(0xFF0F6E56);
  static const Color accentGreen = Color(0xFF1D9E75);
  static const Color lightGreen = Color(0xFF9FE1CB);

  // ── Warm neutrals ─────────────────────────────────────────────────────────
  static const Color cream = Color(0xFFF4EFE4);
  static const Color lightCream = Color(0xFFFBF7EE);
  static const Color borderBeige = Color(0xFFE3D9C2);
  static const Color warmBeige = Color(0xFFE8DDC4);
  static const Color veryLightBeige = Color(0xFFF7F2E7);
  static const Color cardBeige = Color(0xFFEFE7D3);

  // ── Browns / text ──────────────────────────────────────────────────────────
  static const Color textDark = Color(0xFF4A3A1E);
  static const Color textMid = Color(0xFF6B5C3D);
  static const Color textMuted = Color(0xFF8A7B5C);
  static const Color textMutedLight = Color(0xFFA8997A);
  static const Color darkAmber = Color(0xFF633806);

  // ── Amber / gold ──────────────────────────────────────────────────────────
  static const Color amber = Color(0xFFBA7517);
  static const Color brightYellow = Color(0xFFF7C948);
  static const Color zoneDot = Color(0xFFFFE9B0);

  // ── Navigation background ─────────────────────────────────────────────────
  static const Color navBg = Color(0xFF0B3A2E);
  static const Color navBorder = Color(0xFF1D5544);

  // ── Upper Room (dark amber palette) ───────────────────────────────────────
  static const Color upperRoomBg = Color(0xFF100B06);
  static const Color upperRoomCard = Color(0xFF140D07);
  static const Color upperRoomBorder = Color(0xFF3A2C14);
  static const Color upperRoomAmber = Color(0xFFE0A441);
  static const Color upperRoomAmberLight = Color(0xFFEFB659);
  static const Color upperRoomCream = Color(0xFFF4ECD8);
  static const Color upperRoomMuted = Color(0xFFC9B48A);
  static const Color upperRoomWall = Color(0xFFE8DCC4);
  static const Color upperRoomPlaceholder = Color(0xFF8A7448);

  // ── Stage badge colours ────────────────────────────────────────────────────
  static const Color stageDotDone = Color(0xFF1D9E75);
  static const Color stageDotCurrent = Color(0xFFBA7517);
  static const Color stageDotLocked = Color(0xFFD8CDB2);
  static const Color stageLockedOverlay = Color(0x4D442604);

  // ── Progress / misc ────────────────────────────────────────────────────────
  static const Color progressTrack = Color(0xFFE3D9C2);
  static const Color progressFill = Color(0xFF1D9E75);
  static const Color sessionTrack = Color(0xFFE9E0CB);
}

// ─────────────────────────────────────────────────────────────────────────────
// Season Themes — for the WorldMap
// ─────────────────────────────────────────────────────────────────────────────

class SeasonTheme {
  final String label;
  final Color ocean;
  final Color land;
  final Color border;
  final Color node;
  final Color accent;
  final String caption;

  const SeasonTheme({
    required this.label,
    required this.ocean,
    required this.land,
    required this.border,
    required this.node,
    required this.accent,
    required this.caption,
  });
}

abstract final class SeasonThemes {
  static const spring = SeasonTheme(
    label: 'Spring — Blossom',
    ocean: Color(0xFF07130F),
    land: Color(0xFF12281F),
    border: Color(0xFF1D4D3B),
    node: Color(0xFFF7B8D2),
    accent: Color(0xFFF7C948),
    caption: 'New believers blossoming across the earth.',
  );
  static const summer = SeasonTheme(
    label: 'Summer — Verdant',
    ocean: Color(0xFF06110D),
    land: Color(0xFF0F2A20),
    border: Color(0xFF1D5C44),
    node: Color(0xFF1D9E75),
    accent: Color(0xFFF7C948),
    caption: 'The Church in full, verdant strength.',
  );
  static const autumn = SeasonTheme(
    label: 'Autumn — Harvest',
    ocean: Color(0xFF120C06),
    land: Color(0xFF2A1C0F),
    border: Color(0xFF5C3D1D),
    node: Color(0xFFE0821A),
    accent: Color(0xFFF7C948),
    caption: 'The fields are white for harvest.',
  );
  static const winter = SeasonTheme(
    label: 'Winter — Waiting',
    ocean: Color(0xFF080C11),
    land: Color(0xFF161F2A),
    border: Color(0xFF33445C),
    node: Color(0xFF9FE1CB),
    accent: Color(0xFFCBD8E1),
    caption: 'Quiet, hidden growth beneath the frost.',
  );

  static SeasonTheme of(String season) => switch (season) {
        'spring' => spring,
        'autumn' => autumn,
        'winter' => winter,
        _ => summer,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// App ThemeData
// ─────────────────────────────────────────────────────────────────────────────

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.light,
      primary: AppColors.primaryGreen,
      secondary: AppColors.accentGreen,
      surface: AppColors.lightCream,
    ),
    scaffoldBackgroundColor: AppColors.lightCream,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.primaryGreen,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: AppColors.primaryGreen,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textDark,
        height: 1.65,
        fontSize: 15,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textDark,
        height: 1.6,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: AppColors.textMid,
        height: 1.5,
        fontSize: 12,
      ),
      labelSmall: TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
    dividerColor: AppColors.borderBeige,
    cardTheme: CardTheme(
      color: AppColors.lightCream,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.borderBeige),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderBeige),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderBeige),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accentGreen, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.textMutedLight),
    ),
  );
}
