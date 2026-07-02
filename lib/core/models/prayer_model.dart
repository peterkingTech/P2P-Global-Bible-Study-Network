import 'package:flutter/foundation.dart';

enum PrayerCategory {
  personal,
  nation,
  church,
  healing,
  missions,
  revival,
  intercession,
}

/// A prayer request on the Nation Prayer Wall or Upper Room.
@immutable
class PrayerModel {
  final String id;
  final String userId;
  final String? displayName; // denormalized for wall display
  final String? city;
  final String? country;
  final String request;
  final PrayerCategory category;
  final int prayedCount; // how many people clicked "I prayed this"
  final bool isAnonymous;
  final bool isAnswered;
  final DateTime createdAt;
  final DateTime? answeredAt;

  const PrayerModel({
    required this.id,
    required this.userId,
    this.displayName,
    this.city,
    this.country,
    required this.request,
    this.category = PrayerCategory.personal,
    this.prayedCount = 0,
    this.isAnonymous = false,
    this.isAnswered = false,
    required this.createdAt,
    this.answeredAt,
  });

  factory PrayerModel.fromMap(Map<String, dynamic> map) => PrayerModel(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        displayName: map['display_name'] as String?,
        city: map['city'] as String?,
        country: map['country'] as String?,
        request: map['request'] as String,
        category: PrayerCategory.values.firstWhere(
          (e) => e.name == (map['category'] as String? ?? 'personal'),
          orElse: () => PrayerCategory.personal,
        ),
        prayedCount: (map['prayed_count'] as int?) ?? 0,
        isAnonymous: (map['is_anonymous'] as bool?) ?? false,
        isAnswered: (map['is_answered'] as bool?) ?? false,
        createdAt: DateTime.parse(map['created_at'] as String),
        answeredAt: map['answered_at'] == null
            ? null
            : DateTime.parse(map['answered_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'display_name': displayName,
        'city': city,
        'country': country,
        'request': request,
        'category': category.name,
        'prayed_count': prayedCount,
        'is_anonymous': isAnonymous,
        'is_answered': isAnswered,
        'created_at': createdAt.toIso8601String(),
        'answered_at': answeredAt?.toIso8601String(),
      };

  PrayerModel copyWith({int? prayedCount, bool? isAnswered, DateTime? answeredAt}) =>
      PrayerModel(
        id: id,
        userId: userId,
        displayName: displayName,
        city: city,
        country: country,
        request: request,
        category: category,
        prayedCount: prayedCount ?? this.prayedCount,
        isAnonymous: isAnonymous,
        isAnswered: isAnswered ?? this.isAnswered,
        createdAt: createdAt,
        answeredAt: answeredAt ?? this.answeredAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PrayerModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
