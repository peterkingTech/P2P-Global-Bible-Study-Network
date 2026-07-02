import 'package:flutter/foundation.dart';

enum SessionStatus { scheduled, live, completed, cancelled }

/// A peer-to-peer study session between two believers.
@immutable
class SessionModel {
  final String id;
  final String lessonId;
  final String hostUserId;
  final String guestUserId;
  final SessionStatus status;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final String? hostReflection;
  final String? guestReflection;
  final bool hostCompleted;
  final bool guestCompleted;
  final String? meetingUrl; // e.g. Jitsi / Daily room URL

  const SessionModel({
    required this.id,
    required this.lessonId,
    required this.hostUserId,
    required this.guestUserId,
    this.status = SessionStatus.scheduled,
    required this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.hostReflection,
    this.guestReflection,
    this.hostCompleted = false,
    this.guestCompleted = false,
    this.meetingUrl,
  });

  bool get isLive => status == SessionStatus.live;
  bool get isComplete => status == SessionStatus.completed;

  Duration? get duration => durationSeconds == null
      ? null
      : Duration(seconds: durationSeconds!);

  factory SessionModel.fromMap(Map<String, dynamic> map) => SessionModel(
        id: map['id'] as String,
        lessonId: map['lesson_id'] as String,
        hostUserId: map['host_user_id'] as String,
        guestUserId: map['guest_user_id'] as String,
        status: SessionStatus.values.firstWhere(
          (e) => e.name == (map['status'] as String? ?? 'scheduled'),
          orElse: () => SessionStatus.scheduled,
        ),
        scheduledAt: DateTime.parse(map['scheduled_at'] as String),
        startedAt: map['started_at'] == null
            ? null
            : DateTime.parse(map['started_at'] as String),
        endedAt: map['ended_at'] == null
            ? null
            : DateTime.parse(map['ended_at'] as String),
        durationSeconds: map['duration_seconds'] as int?,
        hostReflection: map['host_reflection'] as String?,
        guestReflection: map['guest_reflection'] as String?,
        hostCompleted: (map['host_completed'] as bool?) ?? false,
        guestCompleted: (map['guest_completed'] as bool?) ?? false,
        meetingUrl: map['meeting_url'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'lesson_id': lessonId,
        'host_user_id': hostUserId,
        'guest_user_id': guestUserId,
        'status': status.name,
        'scheduled_at': scheduledAt.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'duration_seconds': durationSeconds,
        'host_reflection': hostReflection,
        'guest_reflection': guestReflection,
        'host_completed': hostCompleted,
        'guest_completed': guestCompleted,
        'meeting_url': meetingUrl,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SessionModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
