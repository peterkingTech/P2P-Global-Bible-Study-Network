import 'package:flutter/material.dart';

// ── String extensions ─────────────────────────────────────────────────────────

extension StringX on String {
  /// "hello world" → "Hello World"
  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  /// Truncates to [maxLen] with trailing "…"
  String truncate(int maxLen) =>
      length <= maxLen ? this : '${substring(0, maxLen)}…';

  /// Returns `null` if the string is empty, otherwise `this`.
  String? get nullIfEmpty => isEmpty ? null : this;
}

// ── DateTime extensions ───────────────────────────────────────────────────────

extension DateTimeX on DateTime {
  /// `true` if this date is the same calendar day as [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// `true` if this date is today.
  bool get isToday => isSameDay(DateTime.now());

  /// `true` if this date is within the last [days] days.
  bool isWithinDays(int days) =>
      DateTime.now().difference(this).inDays <= days;
}

// ── BuildContext extensions ───────────────────────────────────────────────────

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  MediaQueryData get mq => MediaQuery.of(this);
  double get screenWidth => mq.size.width;
  double get screenHeight => mq.size.height;
  bool get isTablet => screenWidth >= 600;
}

// ── Color extensions ──────────────────────────────────────────────────────────

extension ColorX on Color {
  /// Returns the colour with the given [opacity] (0.0–1.0).
  Color alpha(double opacity) => withOpacity(opacity);
}

// ── Duration extensions ───────────────────────────────────────────────────────

extension DurationX on Duration {
  /// "03:47" — minutes:seconds padded to 2 digits each.
  String get mmSs {
    final m = inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ── List extensions ────────────────────────────────────────────────────────────

extension ListX<T> on List<T> {
  /// Returns [null] if the list is empty; otherwise the first element.
  T? get firstOrNull => isEmpty ? null : first;

  /// Splits the list into chunks of [size].
  List<List<T>> chunked(int size) {
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(sublist(i, (i + size).clamp(0, length)));
    }
    return result;
  }
}
