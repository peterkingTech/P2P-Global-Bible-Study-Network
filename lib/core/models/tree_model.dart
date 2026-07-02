import 'package:flutter/foundation.dart';

/// Visual growth stages for the Living Tree widget and animations.
enum TreeStage {
  dormantSeed,
  sprout,
  youngTree,
  fruitfulTree,
  forestBuilder,
  forestOfNations,
}

/// A living tree represents a believer's spiritual growth record.
///
/// Maps to the `trees` Supabase table, which aggregates lesson completions,
/// peer session hours, disciples made, prayer counts, etc.
@immutable
class TreeModel {
  final String id;
  final String userId;
  final int level; // 0-5 (Seed → Forest)
  final int score; // cumulative growth score
  final int studiesCompleted;
  final int peersConnected;
  final int disciplesMade;
  final int prayersLogged;
  final int streakDays;
  final int nationsReached;
  final double progressToNext; // 0.0-1.0
  final DateTime? lastStudyAt;
  final DateTime updatedAt;

  const TreeModel({
    required this.id,
    required this.userId,
    this.level = 0,
    this.score = 0,
    this.studiesCompleted = 0,
    this.peersConnected = 0,
    this.disciplesMade = 0,
    this.prayersLogged = 0,
    this.streakDays = 0,
    this.nationsReached = 0,
    this.progressToNext = 0.0,
    this.lastStudyAt,
    required this.updatedAt,
  });

  factory TreeModel.fromMap(Map<String, dynamic> map) => TreeModel(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        level: (map['level'] as int?) ?? 0,
        score: (map['score'] as int?) ?? 0,
        studiesCompleted: (map['studies_completed'] as int?) ?? 0,
        peersConnected: (map['peers_connected'] as int?) ?? 0,
        disciplesMade: (map['disciples_made'] as int?) ?? 0,
        prayersLogged: (map['prayers_logged'] as int?) ?? 0,
        streakDays: (map['streak_days'] as int?) ?? 0,
        nationsReached: (map['nations_reached'] as int?) ?? 0,
        progressToNext: ((map['progress_to_next'] as num?) ?? 0).toDouble(),
        lastStudyAt: map['last_study_at'] == null
            ? null
            : DateTime.parse(map['last_study_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'level': level,
        'score': score,
        'studies_completed': studiesCompleted,
        'peers_connected': peersConnected,
        'disciples_made': disciplesMade,
        'prayers_logged': prayersLogged,
        'streak_days': streakDays,
        'nations_reached': nationsReached,
        'progress_to_next': progressToNext,
        'last_study_at': lastStudyAt?.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TreeModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
