import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../models/tree_model.dart';

/// Returns the colour associated with a tree growth level (0–5).
Color growthLevelColor(int level) {
  return switch (level) {
    0 => const Color(0xFF78909C), // Dormant seed — grey-blue
    1 => const Color(0xFF81C784), // Sprout — light green
    2 => const Color(0xFF43A047), // Young tree — medium green
    3 => AppColors.accentGreen,   // Fruitful — vivid green
    4 => const Color(0xFFF7C948), // Forest builder — gold
    5 => const Color(0xFFFFAB40), // Forest of nations — orange gold
    _ => AppColors.accentGreen,
  };
}

/// Returns the emoji associated with a tree growth level (0–5).
String growthLevelEmoji(int level) {
  return switch (level) {
    0 => '🌰',
    1 => '🌱',
    2 => '🌿',
    3 => '🌳',
    4 => '🏡',
    5 => '🌏',
    _ => '🌳',
  };
}

/// Returns the label for a [TreeStage].
String treeStageLabel(TreeStage stage) {
  return switch (stage) {
    TreeStage.dormantSeed => 'Dormant Seed',
    TreeStage.sprout => 'Sprout',
    TreeStage.youngTree => 'Young Tree',
    TreeStage.fruitfulTree => 'Fruitful Tree',
    TreeStage.forestBuilder => 'Forest Builder',
    TreeStage.forestOfNations => 'Forest of Nations',
  };
}

/// Clamps and formats a progress value as a percentage string.
String formatPercent(double v) => '${(v.clamp(0.0, 1.0) * 100).round()}%';

/// Returns a human-readable label for a day-of-week index (1 = Mon).
String weekdayShort(int d) =>
    const ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.clamp(1, 7)];
