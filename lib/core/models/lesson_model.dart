import 'package:flutter/foundation.dart';

enum LessonType { reading, video, discussion, memorisation, practicum }

/// A single lesson within a [ModuleModel].
@immutable
class LessonModel {
  final String id;
  final String moduleId;
  final String title;
  final String? subtitle;
  final String content; // Markdown / rich text
  final String? memoryVerse;
  final String? memoryVerseRef; // e.g. "John 15:5"
  final LessonType type;
  final int order;
  final int estimatedMinutes;
  final bool isCompleted; // user-specific
  final DateTime? completedAt;
  final String? checkpointRubric; // Markdown rubric for peer checkpoint

  const LessonModel({
    required this.id,
    required this.moduleId,
    required this.title,
    this.subtitle,
    this.content = '',
    this.memoryVerse,
    this.memoryVerseRef,
    this.type = LessonType.reading,
    this.order = 0,
    this.estimatedMinutes = 20,
    this.isCompleted = false,
    this.completedAt,
    this.checkpointRubric,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map) => LessonModel(
        id: map['id'] as String,
        moduleId: map['module_id'] as String,
        title: map['title'] as String,
        subtitle: map['subtitle'] as String?,
        content: map['content'] as String? ?? '',
        memoryVerse: map['memory_verse'] as String?,
        memoryVerseRef: map['memory_verse_ref'] as String?,
        type: LessonType.values.firstWhere(
          (e) => e.name == (map['type'] as String? ?? 'reading'),
          orElse: () => LessonType.reading,
        ),
        order: (map['order'] as int?) ?? 0,
        estimatedMinutes: (map['estimated_minutes'] as int?) ?? 20,
        isCompleted: (map['is_completed'] as bool?) ?? false,
        completedAt: map['completed_at'] == null
            ? null
            : DateTime.parse(map['completed_at'] as String),
        checkpointRubric: map['checkpoint_rubric'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'module_id': moduleId,
        'title': title,
        'subtitle': subtitle,
        'content': content,
        'memory_verse': memoryVerse,
        'memory_verse_ref': memoryVerseRef,
        'type': type.name,
        'order': order,
        'estimated_minutes': estimatedMinutes,
        'is_completed': isCompleted,
        'completed_at': completedAt?.toIso8601String(),
        'checkpoint_rubric': checkpointRubric,
      };

  LessonModel copyWith({bool? isCompleted, DateTime? completedAt}) =>
      LessonModel(
        id: id,
        moduleId: moduleId,
        title: title,
        subtitle: subtitle,
        content: content,
        memoryVerse: memoryVerse,
        memoryVerseRef: memoryVerseRef,
        type: type,
        order: order,
        estimatedMinutes: estimatedMinutes,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
        checkpointRubric: checkpointRubric,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LessonModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
