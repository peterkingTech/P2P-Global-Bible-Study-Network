import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// A smart-match result from the algorithm.
class SmartMatchResult {
  final UserModel user;
  final double score; // 0-1
  final Map<String, double> breakdown;

  const SmartMatchResult({
    required this.user,
    required this.score,
    required this.breakdown,
  });
}

/// Returns top-3 smart-match results based on questionnaire answers.
final smartMatchResultsProvider =
    FutureProvider.family<List<SmartMatchResult>, List<String>>(
        (ref, answers) async {
  final supabase = Supabase.instance.client;
  final me = supabase.auth.currentUser;
  if (me == null) return [];

  // Derive preferences from answers
  final timePreference = answers.isNotEmpty ? answers[0] : null;
  final priorityFactor = answers.length > 1 ? answers[1] : null;
  final videoComfort = answers.length > 2 ? answers[2] : null;

  final raw = await supabase
      .from('profiles')
      .select()
      .neq('id', me.id)
      .eq('is_discoverable', true)
      .limit(20);

  final users = (raw as List)
      .map((j) => UserModel.fromMap(j as Map<String, dynamic>))
      .toList();

  // Weighted scoring
  final results = users.map((u) {
    double languageScore = 0;
    double timezoneScore = 0;
    double activityScore = u.lastActiveAt != null &&
            DateTime.now().difference(u.lastActiveAt!).inDays < 7
        ? 0.15
        : 0;

    if (priorityFactor == 'Same language' && u.languageCode != null) {
      languageScore = 0.25;
    } else if (priorityFactor == 'Same timezone') {
      timezoneScore = 0.2;
    }

    final score =
        (0.5 + languageScore + timezoneScore + activityScore).clamp(0.0, 1.0);

    return SmartMatchResult(
      user: u,
      score: score,
      breakdown: {
        'language': languageScore,
        'timezone': timezoneScore,
        'activity': activityScore,
      },
    );
  }).toList();

  results.sort((a, b) => b.score.compareTo(a.score));
  return results.take(3).toList();
});
