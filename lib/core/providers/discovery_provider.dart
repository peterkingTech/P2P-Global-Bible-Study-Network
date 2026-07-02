import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Filter parameters for the discovery search.
class DiscoveryFilters {
  final String? language;
  final int? timezoneRange; // ±hours
  final bool sameCountry;
  final int? maxStageDiff;
  final bool recentlyActive;

  const DiscoveryFilters({
    this.language,
    this.timezoneRange,
    this.sameCountry = false,
    this.maxStageDiff,
    this.recentlyActive = false,
  });

  bool get hasAny =>
      language != null || timezoneRange != null || sameCountry || maxStageDiff != null;

  DiscoveryFilters copyWith({
    String? language,
    int? timezoneRange,
    bool? sameCountry,
    int? maxStageDiff,
    bool? recentlyActive,
  }) {
    return DiscoveryFilters(
      language: language ?? this.language,
      timezoneRange: timezoneRange ?? this.timezoneRange,
      sameCountry: sameCountry ?? this.sameCountry,
      maxStageDiff: maxStageDiff ?? this.maxStageDiff,
      recentlyActive: recentlyActive ?? this.recentlyActive,
    );
  }
}

/// A peer result with a compatibility score.
class DiscoveryResult {
  final UserModel user;
  final double score; // 0-1

  const DiscoveryResult({required this.user, required this.score});
}

/// Provider that returns discovery results for the given filters.
final discoveryResultsProvider =
    FutureProvider.family<List<DiscoveryResult>, DiscoveryFilters>(
        (ref, filters) async {
  final supabase = Supabase.instance.client;
  final me = supabase.auth.currentUser;
  if (me == null) return [];

  var query = supabase
      .from('profiles')
      .select()
      .neq('id', me.id)
      .eq('is_discoverable', true);

  if (filters.language != null) {
    query = query.eq('language_code', filters.language!);
  }

  final raw = await query.limit(30);
  final users = (raw as List)
      .map((j) => UserModel.fromMap(j as Map<String, dynamic>))
      .toList();

  // Simple client-side scoring
  final results = users.map((u) {
    double score = 0.5;
    if (filters.language != null && u.languageCode == filters.language) score += 0.2;
    if (filters.sameCountry && u.country != null) score += 0.05;
    return DiscoveryResult(user: u, score: score.clamp(0.0, 1.0));
  }).toList();

  results.sort((a, b) => b.score.compareTo(a.score));
  return results;
});
