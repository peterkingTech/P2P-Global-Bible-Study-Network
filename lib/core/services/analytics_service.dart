import 'supabase_service.dart';

/// Lightweight analytics service that logs user behaviour events to
/// a Supabase `analytics_events` table.
///
/// For production, consider replacing or augmenting with PostHog, Mixpanel,
/// or Firebase Analytics via their respective Flutter SDKs.
class AnalyticsService {
  AnalyticsService._();

  static const String _table = 'analytics_events';

  // ── Event names ────────────────────────────────────────────────────────────
  static const String kLessonStarted = 'lesson_started';
  static const String kLessonCompleted = 'lesson_completed';
  static const String kSessionStarted = 'session_started';
  static const String kSessionCompleted = 'session_completed';
  static const String kPrayerSubmitted = 'prayer_submitted';
  static const String kPrayerPrayed = 'prayer_prayed';
  static const String kMatchRequested = 'match_requested';
  static const String kForestViewed = 'forest_viewed';
  static const String kGrowthLevelUp = 'growth_level_up';

  // ── Log ────────────────────────────────────────────────────────────────────

  /// Logs an analytics event. Fire-and-forget — errors are swallowed to
  /// avoid blocking the UI.
  static Future<void> log(
    String event, {
    String? userId,
    Map<String, dynamic>? properties,
  }) async {
    try {
      await SupabaseService.client.from(_table).insert({
        'event': event,
        'user_id': userId ?? SupabaseService.client.auth.currentUser?.id,
        'properties': properties ?? {},
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Analytics failures must never crash the app.
    }
  }

  // ── Convenience methods ────────────────────────────────────────────────────

  static Future<void> lessonStarted(String lessonId) =>
      log(kLessonStarted, properties: {'lesson_id': lessonId});

  static Future<void> lessonCompleted(String lessonId) =>
      log(kLessonCompleted, properties: {'lesson_id': lessonId});

  static Future<void> sessionStarted(String sessionId) =>
      log(kSessionStarted, properties: {'session_id': sessionId});

  static Future<void> sessionCompleted(String sessionId, int durationSec) =>
      log(kSessionCompleted, properties: {
        'session_id': sessionId,
        'duration_seconds': durationSec,
      });

  static Future<void> growthLevelUp(int newLevel) =>
      log(kGrowthLevelUp, properties: {'new_level': newLevel});

  static Future<void> forestViewed(String season) =>
      log(kForestViewed, properties: {'season': season});
}
