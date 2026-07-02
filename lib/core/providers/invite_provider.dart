import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invite_model.dart';
import 'auth_provider.dart';

/// Generates (or fetches the most recent active) invite link for the current user.
final inviteLinkProvider = FutureProvider<String>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');

  final userId = user.id;

  // Check for an existing active link
  final existing = await Supabase.instance.client
      .from('invite_links')
      .select()
      .eq('inviter_id', userId)
      .eq('status', 'pending')
      .gt('expires_at', DateTime.now().toIso8601String())
      .maybeSingle();

  if (existing != null) {
    final model = InviteModel.fromJson(existing);
    return 'https://p2pglobal.app/join/${model.code}';
  }

  // Create a new link
  final code = _generateCode();
  final expiresAt = DateTime.now().add(const Duration(days: 7));

  await Supabase.instance.client.from('invite_links').insert({
    'inviter_id': userId,
    'code': code,
    'status': 'pending',
    'expires_at': expiresAt.toIso8601String(),
  });

  return 'https://p2pglobal.app/join/$code';
});

String _generateCode() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rng = DateTime.now().millisecondsSinceEpoch;
  var result = '';
  var seed = rng;
  for (var i = 0; i < 8; i++) {
    result += chars[seed % chars.length];
    seed ~/= 2;
    seed += rng ~/ (i + 1);
  }
  return result;
}
