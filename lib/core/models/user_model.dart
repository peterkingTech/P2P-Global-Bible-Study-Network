import 'package:flutter/foundation.dart';

/// Spiritual gifts that shape a believer's service role.
enum SpiritualGift {
  teaching,
  evangelism,
  mercy,
  leadership,
  intercession,
  hospitality,
  giving,
  prophecy,
}

/// The user's primary role in the discipleship network.
enum DiscipleRole { seeker, disciple, mentor, elder }

/// Core user profile — mirrors the `users` Supabase table.
@immutable
class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final String? city;
  final String? country;
  final String? languageCode; // BCP-47
  final int growthLevel; // 0-5
  final DiscipleRole role;
  final List<SpiritualGift> gifts;
  final String? mentorId;
  final bool isPraying;
  final DateTime? lastActiveAt;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.city,
    this.country,
    this.languageCode = 'en',
    this.growthLevel = 0,
    this.role = DiscipleRole.disciple,
    this.gifts = const [],
    this.mentorId,
    this.isPraying = false,
    this.lastActiveAt,
    required this.createdAt,
  });

  /// Deserialise from a Supabase row map.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      displayName: map['display_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      city: map['city'] as String?,
      country: map['country'] as String?,
      languageCode: map['language_code'] as String? ?? 'en',
      growthLevel: (map['growth_level'] as int?) ?? 0,
      role: DiscipleRole.values.firstWhere(
        (e) => e.name == (map['role'] as String? ?? 'disciple'),
        orElse: () => DiscipleRole.disciple,
      ),
      gifts: ((map['gifts'] as List<dynamic>?) ?? [])
          .map((g) => SpiritualGift.values.firstWhere(
                (e) => e.name == g,
                orElse: () => SpiritualGift.teaching,
              ))
          .toList(),
      mentorId: map['mentor_id'] as String?,
      isPraying: (map['is_praying'] as bool?) ?? false,
      lastActiveAt: map['last_active_at'] == null
          ? null
          : DateTime.parse(map['last_active_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'display_name': displayName,
        'email': email,
        'avatar_url': avatarUrl,
        'city': city,
        'country': country,
        'language_code': languageCode,
        'growth_level': growthLevel,
        'role': role.name,
        'gifts': gifts.map((g) => g.name).toList(),
        'mentor_id': mentorId,
        'is_praying': isPraying,
        'last_active_at': lastActiveAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? displayName,
    String? avatarUrl,
    String? city,
    String? country,
    String? languageCode,
    int? growthLevel,
    DiscipleRole? role,
    List<SpiritualGift>? gifts,
    String? mentorId,
    bool? isPraying,
    DateTime? lastActiveAt,
  }) =>
      UserModel(
        id: id,
        displayName: displayName ?? this.displayName,
        email: email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        city: city ?? this.city,
        country: country ?? this.country,
        languageCode: languageCode ?? this.languageCode,
        growthLevel: growthLevel ?? this.growthLevel,
        role: role ?? this.role,
        gifts: gifts ?? this.gifts,
        mentorId: mentorId ?? this.mentorId,
        isPraying: isPraying ?? this.isPraying,
        lastActiveAt: lastActiveAt ?? this.lastActiveAt,
        createdAt: createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
