import 'package:flutter/foundation.dart';

/// A discipleship curriculum module (e.g. "Foundations", "Kingdom Life").
@immutable
class ModuleModel {
  final String id;
  final String title;
  final String description;
  final int order; // display order
  final int requiredLevel; // minimum tree level to unlock
  final String? imageAsset; // local asset path
  final String? imageUrl; // remote CDN URL
  final int totalLessons;
  final int completedLessons; // user-specific, joined from progress table
  final bool isUnlocked;
  final DateTime? completedAt;

  const ModuleModel({
    required this.id,
    required this.title,
    required this.description,
    this.order = 0,
    this.requiredLevel = 0,
    this.imageAsset,
    this.imageUrl,
    this.totalLessons = 0,
    this.completedLessons = 0,
    this.isUnlocked = false,
    this.completedAt,
  });

  double get progress =>
      totalLessons == 0 ? 0.0 : completedLessons / totalLessons;

  bool get isComplete => completedLessons >= totalLessons && totalLessons > 0;

  factory ModuleModel.fromMap(Map<String, dynamic> map) => ModuleModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        order: (map['order'] as int?) ?? 0,
        requiredLevel: (map['required_level'] as int?) ?? 0,
        imageAsset: map['image_asset'] as String?,
        imageUrl: map['image_url'] as String?,
        totalLessons: (map['total_lessons'] as int?) ?? 0,
        completedLessons: (map['completed_lessons'] as int?) ?? 0,
        isUnlocked: (map['is_unlocked'] as bool?) ?? false,
        completedAt: map['completed_at'] == null
            ? null
            : DateTime.parse(map['completed_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'order': order,
        'required_level': requiredLevel,
        'image_asset': imageAsset,
        'image_url': imageUrl,
        'total_lessons': totalLessons,
        'completed_lessons': completedLessons,
        'is_unlocked': isUnlocked,
        'completed_at': completedAt?.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ModuleModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
