import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around [SupabaseClient] that centralises table names and
/// provides typed helper methods used across other services.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  // ── Table names ────────────────────────────────────────────────────────────
  static const String usersTable = 'users';
  static const String treesTable = 'trees';
  static const String modulesTable = 'modules';
  static const String lessonsTable = 'lessons';
  static const String progressTable = 'lesson_progress';
  static const String sessionsTable = 'sessions';
  static const String fruitsTable = 'fruits';
  static const String prayersTable = 'prayers';
  static const String prayedTable = 'prayed'; // junction: user ↔ prayer
  static const String forestNodesView = 'forest_nodes'; // materialised view

  // ── Storage bucket names ────────────────────────────────────────────────────
  static const String avatarsBucket = 'avatars';
  static const String assetsBucket = 'app-assets';

  // ── Realtime channel names ──────────────────────────────────────────────────
  static const String prayerChannel = 'prayer-wall';
  static const String presenceChannel = 'user-presence';

  // ── Convenience getters ────────────────────────────────────────────────────

  static PostgrestFilterBuilder get users =>
      client.from(usersTable).select();

  static PostgrestFilterBuilder get trees =>
      client.from(treesTable).select();

  static PostgrestFilterBuilder get modules =>
      client.from(modulesTable).select();

  static PostgrestFilterBuilder get lessons =>
      client.from(lessonsTable).select();

  static PostgrestFilterBuilder get sessions =>
      client.from(sessionsTable).select();

  static PostgrestFilterBuilder get prayers =>
      client.from(prayersTable).select();

  static PostgrestFilterBuilder get forestNodes =>
      client.from(forestNodesView).select();

  // ── Storage helpers ────────────────────────────────────────────────────────

  /// Returns a public URL for [path] in the [avatarsBucket].
  static String avatarUrl(String path) =>
      client.storage.from(avatarsBucket).getPublicUrl(path);

  /// Uploads [bytes] as [path] in the [avatarsBucket] and returns the URL.
  static Future<String> uploadAvatar(String path, Uint8List bytes) async {
    await client.storage
        .from(avatarsBucket)
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return avatarUrl(path);
  }

  // ── Realtime helpers ────────────────────────────────────────────────────────

  /// Subscribe to changes on [table] filtered by [column] = [value].
  static RealtimeChannel subscribeToTable({
    required String table,
    required String channelName,
    required void Function(PostgresChangePayload) onInsert,
    required void Function(PostgresChangePayload) onUpdate,
    required void Function(PostgresChangePayload) onDelete,
    String? column,
    String? value,
  }) {
    var filter = client.channel(channelName).onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          filter: column != null && value != null
              ? PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: column,
                  value: value,
                )
              : null,
          callback: onInsert,
        );

    filter = filter.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: table,
      filter: column != null && value != null
          ? PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: column,
              value: value,
            )
          : null,
      callback: onUpdate,
    );

    filter = filter.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: table,
      callback: onDelete,
    );

    return filter..subscribe();
  }
}
