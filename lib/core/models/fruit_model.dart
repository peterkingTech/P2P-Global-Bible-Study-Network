import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// The 16 fruits of discipleship — each maps to a character trait a disciple
/// demonstrates over time and receives peer-checkpoint validation for.
class FruitModel {
  final String type;
  final String name;
  final String emoji;
  final String description;
  final String howToEarn;
  final bool isSecret;
  final bool isEarned;
  final DateTime? earnedAt;
  final String? earnedReason;

  const FruitModel({
    required this.type,
    required this.name,
    required this.emoji,
    required this.description,
    required this.howToEarn,
    this.isSecret = false,
    this.isEarned = false,
    this.earnedAt,
    this.earnedReason,
  });

  factory FruitModel.fromJson(Map<String, dynamic> json) => FruitModel(
        type: json['type'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        description: json['description'] as String,
        howToEarn: (json['how_to_earn'] as String?) ?? '',
        isSecret: (json['is_secret'] as bool?) ?? false,
        isEarned: (json['is_earned'] as bool?) ?? false,
        earnedAt: json['earned_at'] == null
            ? null
            : DateTime.parse(json['earned_at'] as String),
        earnedReason: json['earned_reason'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'emoji': emoji,
        'description': description,
        'how_to_earn': howToEarn,
        'is_secret': isSecret,
        'is_earned': isEarned,
        'earned_at': earnedAt?.toIso8601String(),
        'earned_reason': earnedReason,
      };

  FruitModel copyWith({
    String? type,
    String? name,
    String? emoji,
    String? description,
    String? howToEarn,
    bool? isSecret,
    bool? isEarned,
    DateTime? earnedAt,
    String? earnedReason,
  }) =>
      FruitModel(
        type: type ?? this.type,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        description: description ?? this.description,
        howToEarn: howToEarn ?? this.howToEarn,
        isSecret: isSecret ?? this.isSecret,
        isEarned: isEarned ?? this.isEarned,
        earnedAt: earnedAt ?? this.earnedAt,
        earnedReason: earnedReason ?? this.earnedReason,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FruitModel && other.type == type;

  @override
  int get hashCode => type.hashCode;
}

/// Extension that resolves the display colour for a fruit without serialising
/// a [Color] value (which is not JSON-safe).
extension FruitModelX on FruitModel {
  Color get color {
    return switch (type) {
      'love' => Colors.redAccent,
      'joy' => AppColors.amber,
      'peace' => const Color(0xFF4ECDC4),
      'faith' => const Color(0xFF5C6BC0),
      'prayer' => AppColors.upperRoomAmber,
      'word' => AppColors.primaryGreen,
      'evangelism' => AppColors.accentGreen,
      'discipleship' => AppColors.lightGreen,
      'compassion' => const Color(0xFF66BB6A),
      'obedience' => const Color(0xFF7B61FF),
      'integrity' => const Color(0xFF78909C),
      'faithfulness' => AppColors.amber,
      'community' => const Color(0xFF26C6DA),
      'harvest' => const Color(0xFFD4A017),
      'barnabas' => AppColors.amber,
      'timothy' => AppColors.amber,
      _ => AppColors.accentGreen,
    };
  }
}
