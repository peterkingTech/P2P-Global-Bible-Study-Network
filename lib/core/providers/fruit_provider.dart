import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fruit_model.dart';

/// All 16 fruit types with earned status for the current user.
final fruitsProvider = FutureProvider<List<FruitModel>>((ref) async {
  final supabase = Supabase.instance.client;
  final me = supabase.auth.currentUser;
  if (me == null) return _kAllFruits;

  // Fetch which fruits this user has earned
  final earned = await supabase
      .from('user_fruits')
      .select()
      .eq('user_id', me.id);

  final earnedMap = {
    for (final f in (earned as List))
      f['fruit_type'] as String: f,
  };

  return _kAllFruits.map((f) {
    final earnedData = earnedMap[f.type];
    if (earnedData == null) return f;
    return f.copyWith(
      isEarned: true,
      earnedAt: DateTime.tryParse(earnedData['earned_at'] ?? ''),
      earnedReason: earnedData['reason'] as String?,
    );
  }).toList();
});

// ── Faithfulness stats ────────────────────────────────────────────────────────

class FaithfulnessStats {
  final int wisdomPoints;
  final int faithfulnessXp;
  final int fruitPoints;
  final int servantScore;

  const FaithfulnessStats({
    this.wisdomPoints = 0,
    this.faithfulnessXp = 0,
    this.fruitPoints = 0,
    this.servantScore = 0,
  });
}

final faithfulnessStatsProvider = FutureProvider<FaithfulnessStats>((ref) async {
  final supabase = Supabase.instance.client;
  final me = supabase.auth.currentUser;
  if (me == null) return const FaithfulnessStats();

  final data = await supabase
      .from('faithfulness_points')
      .select()
      .eq('user_id', me.id)
      .maybeSingle();

  if (data == null) return const FaithfulnessStats();

  return FaithfulnessStats(
    wisdomPoints: (data['wisdom_points'] ?? 0) as int,
    faithfulnessXp: (data['faithfulness_xp'] ?? 0) as int,
    fruitPoints: (data['fruit_points'] ?? 0) as int,
    servantScore: (data['servant_score'] ?? 0) as int,
  );
});

// ── Seed data — all 16 fruit types ───────────────────────────────────────────

const _kAllFruits = [
  FruitModel(
    type: 'love',
    name: 'Love',
    emoji: '❤️',
    description: 'Demonstrated consistently loving others above yourself.',
    howToEarn: 'Shown through peer-confirmed acts of sacrificial care.',
    isSecret: false,
  ),
  FruitModel(
    type: 'joy',
    name: 'Joy',
    emoji: '😊',
    description: 'Expressed persistent joy even through difficulty.',
    howToEarn: 'Observed by peers over 4+ weeks.',
    isSecret: false,
  ),
  FruitModel(
    type: 'peace',
    name: 'Peace',
    emoji: '🕊️',
    description: 'Consistently brought calm and reconciliation.',
    howToEarn: 'Confirmed by peer guide after a conflict resolved.',
    isSecret: false,
  ),
  FruitModel(
    type: 'faith',
    name: 'Faith',
    emoji: '⚓',
    description: 'Maintained trust in God through seasons of waiting.',
    howToEarn: 'System-observed: 30+ days without quitting.',
    isSecret: false,
  ),
  FruitModel(
    type: 'prayer',
    name: 'Prayer',
    emoji: '🙏',
    description: 'Developed a consistent and sincere prayer life.',
    howToEarn: '21+ days of prayer submissions in the root network.',
    isSecret: false,
  ),
  FruitModel(
    type: 'word',
    name: 'Word',
    emoji: '📖',
    description: 'Demonstrated a deepening knowledge of Scripture.',
    howToEarn: 'Complete all memory verse tests in 3 modules.',
    isSecret: false,
  ),
  FruitModel(
    type: 'evangelism',
    name: 'Evangelism',
    emoji: '🌍',
    description: 'Shared the good news with someone outside the app.',
    howToEarn: 'Submit a weekly challenge report with a conversion.',
    isSecret: false,
  ),
  FruitModel(
    type: 'discipleship',
    name: 'Discipleship',
    emoji: '🌱',
    description: 'Mentored a peer through their first complete module.',
    howToEarn: 'Your mentee completes Module 1.',
    isSecret: false,
  ),
  FruitModel(
    type: 'compassion',
    name: 'Compassion',
    emoji: '💚',
    description: 'Went beyond what was expected to care for another.',
    howToEarn: 'Peer confirms a specific act of compassion.',
    isSecret: false,
  ),
  FruitModel(
    type: 'obedience',
    name: 'Obedience',
    emoji: '🎯',
    description: 'Said yes to God in a difficult or costly situation.',
    howToEarn: 'Reported in the assignment tracker, confirmed by peer.',
    isSecret: false,
  ),
  FruitModel(
    type: 'integrity',
    name: 'Integrity',
    emoji: '🏛️',
    description: 'Maintained consistent honesty even when it cost you.',
    howToEarn: 'Peer-confirmed over 2+ month relationship.',
    isSecret: false,
  ),
  FruitModel(
    type: 'faithfulness',
    name: 'Faithfulness',
    emoji: '🕯️',
    description: 'Stayed the course through 90 days of consistent engagement.',
    howToEarn: '90-day streak without going dormant.',
    isSecret: false,
  ),
  FruitModel(
    type: 'community',
    name: 'Community',
    emoji: '🤝',
    description: 'Actively contributed to your peer community.',
    howToEarn: '5+ sessions completed and prayer for 10+ others.',
    isSecret: false,
  ),
  FruitModel(
    type: 'harvest',
    name: 'Harvest',
    emoji: '🌾',
    description: 'Participated in a Mega Harvest event.',
    howToEarn: 'Submit a conversation or decision log on Harvest Day.',
    isSecret: false,
  ),
  FruitModel(
    type: 'barnabas',
    name: 'Barnabas',
    emoji: '🌟',
    description: 'A secret fruit for those who quietly encourage others.',
    howToEarn: 'Given secretly — keep encouraging.',
    isSecret: true,
  ),
  FruitModel(
    type: 'timothy',
    name: 'Timothy',
    emoji: '🔥',
    description: 'Your mentee became a mentor — the chain continues.',
    howToEarn: 'Your mentee disciples someone else.',
    isSecret: true,
  ),
];
