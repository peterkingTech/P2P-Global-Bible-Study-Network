import 'package:flutter/foundation.dart';

/// A node in the Global Forest — a lightweight view of a single believer's
/// location, level, and connection status, used for map rendering.
///
/// Kept deliberately lean (no full profile) for fast paginated fetches.
@immutable
class ForestNodeModel {
  final String userId;
  final String displayName;
  final double longitude;
  final double latitude;
  final String? city;
  final String? country;
  final int level; // 0-5
  final bool isPraying;
  final bool isRecentlyActive; // active in last 7 days
  final String? mentorId; // for drawing connection edges
  final bool covenantBond; // Paul-Timothy relationship
  final DateTime? lastActiveAt;

  const ForestNodeModel({
    required this.userId,
    required this.displayName,
    required this.longitude,
    required this.latitude,
    this.city,
    this.country,
    this.level = 0,
    this.isPraying = false,
    this.isRecentlyActive = false,
    this.mentorId,
    this.covenantBond = false,
    this.lastActiveAt,
  });

  factory ForestNodeModel.fromMap(Map<String, dynamic> map) => ForestNodeModel(
        userId: map['user_id'] as String,
        displayName: map['display_name'] as String? ?? 'Anonymous',
        longitude: ((map['longitude'] as num?) ?? 0).toDouble(),
        latitude: ((map['latitude'] as num?) ?? 0).toDouble(),
        city: map['city'] as String?,
        country: map['country'] as String?,
        level: (map['level'] as int?) ?? 0,
        isPraying: (map['is_praying'] as bool?) ?? false,
        isRecentlyActive: (map['is_recently_active'] as bool?) ?? false,
        mentorId: map['mentor_id'] as String?,
        covenantBond: (map['covenant_bond'] as bool?) ?? false,
        lastActiveAt: map['last_active_at'] == null
            ? null
            : DateTime.parse(map['last_active_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'display_name': displayName,
        'longitude': longitude,
        'latitude': latitude,
        'city': city,
        'country': country,
        'level': level,
        'is_praying': isPraying,
        'is_recently_active': isRecentlyActive,
        'mentor_id': mentorId,
        'covenant_bond': covenantBond,
        'last_active_at': lastActiveAt?.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForestNodeModel && other.userId == userId;

  @override
  int get hashCode => userId.hashCode;
}
