import '../models/user_model.dart';
import 'supabase_service.dart';

/// Finds compatible peer-study partners using a Supabase RPC function.
///
/// Matching criteria (ranked by score):
///   1. Same primary language
///   2. ±1 growth level
///   3. Complementary spiritual gifts
///   4. Geographic proximity (haversine, within configurable km)
///   5. Shared available time window
class MatchingService {
  /// Returns up to [limit] suggested partners for [userId].
  ///
  /// Calls the `find_matches` Postgres RPC function which runs the
  /// multi-criteria scoring in SQL for efficiency.
  Future<List<UserModel>> findMatches({
    required String userId,
    int limit = 10,
    int radiusKm = 50,
  }) async {
    final rows = await SupabaseService.client.rpc(
      'find_matches',
      params: {
        'p_user_id': userId,
        'p_limit': limit,
        'p_radius_km': radiusKm,
      },
    ) as List<dynamic>;

    return rows
        .cast<Map<String, dynamic>>()
        .map(UserModel.fromMap)
        .toList();
  }

  /// Records that [requesterId] sent a session invite to [targetId].
  Future<void> sendInvite({
    required String requesterId,
    required String targetId,
    required String lessonId,
  }) =>
      SupabaseService.client.from('session_invites').insert({
        'requester_id': requesterId,
        'target_id': targetId,
        'lesson_id': lessonId,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

  /// Accepts [inviteId] and creates a live [SessionModel] row.
  Future<void> acceptInvite(String inviteId) =>
      SupabaseService.client.rpc(
        'accept_invite',
        params: {'p_invite_id': inviteId},
      );

  /// Declines [inviteId].
  Future<void> declineInvite(String inviteId) =>
      SupabaseService.client
          .from('session_invites')
          .update({'status': 'declined'}).eq('id', inviteId);

  /// Streams incoming invites for [userId] in real time.
  Stream<List<Map<String, dynamic>>> watchInvites(String userId) =>
      SupabaseService.client
          .from('session_invites')
          .stream(primaryKey: ['id'])
          .eq('target_id', userId)
          .map((rows) => rows
              .where((r) => r['status'] == 'pending')
              .cast<Map<String, dynamic>>()
              .toList());
}
