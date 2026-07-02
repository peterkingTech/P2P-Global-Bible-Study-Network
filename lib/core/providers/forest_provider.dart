import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/forest_node_model.dart';
import '../services/supabase_service.dart';

// ── Filter state ───────────────────────────────────────────────────────────────

@immutable
class ForestFilters {
  final String season; // spring|summer|autumn|winter
  final Set<int> stages;
  final String activity; // all|praying|recent
  final String relationship; // all|disciples|mentors

  const ForestFilters({
    this.season = 'summer',
    this.stages = const {},
    this.activity = 'all',
    this.relationship = 'all',
  });

  ForestFilters copyWith({
    String? season,
    Set<int>? stages,
    String? activity,
    String? relationship,
  }) =>
      ForestFilters(
        season: season ?? this.season,
        stages: stages ?? this.stages,
        activity: activity ?? this.activity,
        relationship: relationship ?? this.relationship,
      );
}

class ForestFiltersNotifier extends StateNotifier<ForestFilters> {
  ForestFiltersNotifier() : super(const ForestFilters());

  void setSeason(String season) => state = state.copyWith(season: season);

  void toggleStage(int level) {
    final next = Set<int>.from(state.stages);
    if (next.contains(level)) {
      next.remove(level);
    } else {
      next.add(level);
    }
    state = state.copyWith(stages: next);
  }

  void setActivity(String activity) =>
      state = state.copyWith(activity: activity);

  void setRelationship(String relationship) =>
      state = state.copyWith(relationship: relationship);

  void reset() => state = const ForestFilters();
}

final forestFiltersProvider =
    StateNotifierProvider<ForestFiltersNotifier, ForestFilters>(
  (ref) => ForestFiltersNotifier(),
);

// ── Forest node data ───────────────────────────────────────────────────────────

final forestNodesProvider =
    FutureProvider<List<ForestNodeModel>>((ref) async {
  final filters = ref.watch(forestFiltersProvider);

  var query = SupabaseService.client
      .from(SupabaseService.forestNodesView)
      .select();

  if (filters.activity == 'praying') {
    query = query.eq('is_praying', true);
  } else if (filters.activity == 'recent') {
    query = query.eq('is_recently_active', true);
  }

  if (filters.stages.isNotEmpty) {
    query = query.inFilter('level', filters.stages.toList());
  }

  final rows = await query;
  return (rows as List).map((r) => ForestNodeModel.fromMap(r)).toList();
});

// ── Global stats ───────────────────────────────────────────────────────────────

@immutable
class GlobalForestStats {
  final int totalBelievers;
  final int citiesReached;
  final int prayingNow;
  final int covenantBonds;

  const GlobalForestStats({
    this.totalBelievers = 0,
    this.citiesReached = 0,
    this.prayingNow = 0,
    this.covenantBonds = 0,
  });

  factory GlobalForestStats.fromMap(Map<String, dynamic> map) =>
      GlobalForestStats(
        totalBelievers: (map['total_believers'] as int?) ?? 0,
        citiesReached: (map['cities_reached'] as int?) ?? 0,
        prayingNow: (map['praying_now'] as int?) ?? 0,
        covenantBonds: (map['covenant_bonds'] as int?) ?? 0,
      );
}

final globalStatsProvider = FutureProvider<GlobalForestStats>((ref) async {
  final data = await SupabaseService.client
      .rpc('get_global_forest_stats') as Map<String, dynamic>?;

  return data == null
      ? const GlobalForestStats()
      : GlobalForestStats.fromMap(data);
});
