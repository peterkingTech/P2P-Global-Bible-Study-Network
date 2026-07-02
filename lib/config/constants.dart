import 'package:flutter/material.dart';

/// App-wide compile-time constants.
///
/// Replace [supabaseUrl] and [supabaseAnonKey] with your project's values
/// (store them in your CI/CD secrets, never hard-code in source control).
abstract final class AppConstants {
  // ── Supabase ───────────────────────────────────────────────────────────────
  /// Your Supabase project URL — e.g. "https://xxxx.supabase.co"
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  /// Supabase anon/public key
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // ── Localisation ───────────────────────────────────────────────────────────
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('de'),
    Locale('fr'),
    Locale('es'),
    Locale('pt'),
    Locale('zh'),
    Locale('ar'),
    Locale('hi'),
    Locale('sw'),
  ];

  // ── App info ───────────────────────────────────────────────────────────────
  static const String appName = 'Peer-to-Peer Global Bible Study Network';
  static const String appShortName = 'P2P Global Bible Study Network';
  static const String appDeveloper = 'AMEN TECH';
  static const String appTagline = 'Discipleship across nations';
  static const String logoUrl =
      'https://omkqkasniakcnmfcwrvs.supabase.co/storage/v1/object/public/P2P%20Official%20Logo/P2P%20Official%20Logo.png';

  // ── Growth stages ──────────────────────────────────────────────────────────
  static const int maxGrowthLevel = 5;

  // ── Session ────────────────────────────────────────────────────────────────
  /// Default peer session duration in minutes
  static const int defaultSessionMinutes = 45;

  /// Seconds before session timeout warning
  static const int sessionWarningSeconds = 300;

  // ── Matching ───────────────────────────────────────────────────────────────
  static const int matchingRadiusKm = 50;
  static const int maxDiscipees = 12;

  // ── Pagination ─────────────────────────────────────────────────────────────
  static const int pageSize = 20;
  static const int prayerWallPageSize = 30;

  // ── Animation durations ────────────────────────────────────────────────────
  static const Duration breatheDuration = Duration(milliseconds: 2800);
  static const Duration glowDuration = Duration(milliseconds: 5500);
  static const Duration swayDuration = Duration(milliseconds: 6000);
  static const Duration fruitPopDuration = Duration(milliseconds: 900);
  static const Duration leafDriftDuration = Duration(seconds: 7);
  static const Duration zoneRingDuration = Duration(milliseconds: 1400);

  // ── Notification channel IDs ───────────────────────────────────────────────
  static const String prayerChannelId = 'prayer_reminders';
  static const String sessionChannelId = 'session_reminders';
  static const String mentorChannelId = 'mentor_alerts';
}
