// ─────────────────────────────────────────────────────────────────────────────
// Growth Stage model + data — mirrors tree-data.ts
// ─────────────────────────────────────────────────────────────────────────────

enum StageId {
  dormantSeed,
  sprout,
  youngTree,
  fruitfulTree,
  forestBuilder,
  forestOfNations,
}

enum ZoneId { roots, trunk, branches, canopy, fruit }

class GrowthStage {
  final StageId id;
  final int level;
  final String name;
  final String emoji;
  final String image;
  final String verse;
  final String description;

  const GrowthStage({
    required this.id,
    required this.level,
    required this.name,
    required this.emoji,
    required this.image,
    required this.verse,
    required this.description,
  });
}

class TapZone {
  final ZoneId id;
  final String label;
  final String theme;
  final String description;
  final String metric; // key into GrowthMetrics
  final String unit;
  final double cx; // % of width
  final double cy; // % of height
  final double r; // % of width, radius

  const TapZone({
    required this.id,
    required this.label,
    required this.theme,
    required this.description,
    required this.metric,
    required this.unit,
    required this.cx,
    required this.cy,
    required this.r,
  });
}

class GrowthMetrics {
  final int studiesCompleted;
  final int peersConnected;
  final int disciples;
  final int prayers;
  final int streakDays;
  final int nationsReached;

  const GrowthMetrics({
    required this.studiesCompleted,
    required this.peersConnected,
    required this.disciples,
    required this.prayers,
    required this.streakDays,
    required this.nationsReached,
  });

  int metricValue(String key) => switch (key) {
        'studiesCompleted' => studiesCompleted,
        'peersConnected' => peersConnected,
        'disciples' => disciples,
        'prayers' => prayers,
        'streakDays' => streakDays,
        'nationsReached' => nationsReached,
        _ => 0,
      };
}

class GrowthResult {
  final int level;
  final GrowthStage stage;
  final int score;
  final double progress; // 0-1
  final bool isMax;
  final int nextThreshold;
  final int toNext;

  const GrowthResult({
    required this.level,
    required this.stage,
    required this.score,
    required this.progress,
    required this.isMax,
    required this.nextThreshold,
    required this.toNext,
  });
}

// ── Static Data ───────────────────────────────────────────────────────────────

const List<GrowthStage> kGrowthStages = [
  GrowthStage(
    id: StageId.dormantSeed,
    level: 0,
    name: 'Dormant Seed',
    emoji: '🌰',
    image: 'assets/tree/stage-0-seed.png',
    verse: 'Unless a seed falls to the ground and dies… — John 12:24',
    description:
        'The journey begins in stillness. A seed rests in the soil, holding the promise of everything to come.',
  ),
  GrowthStage(
    id: StageId.sprout,
    level: 1,
    name: 'Sprout',
    emoji: '🌱',
    image: 'assets/tree/stage-1-sprout.png',
    verse: 'He is like a tree planted by streams of water. — Psalm 1:3',
    description:
        'First light. Tender shoots break the surface as new habits of prayer and Scripture take hold.',
  ),
  GrowthStage(
    id: StageId.youngTree,
    level: 2,
    name: 'Young Tree',
    emoji: '🌿',
    image: 'assets/tree/stage-2-young.png',
    verse: 'Rooted and built up in Him. — Colossians 2:7',
    description:
        'A trunk forms and branches reach outward. Consistency is turning belief into a settled root system.',
  ),
  GrowthStage(
    id: StageId.fruitfulTree,
    level: 3,
    name: 'Fruitful Tree',
    emoji: '🌳',
    image: 'assets/tree/stage-3-fruitful.png',
    verse: 'By their fruit you will recognize them. — Matthew 7:20',
    description:
        'The canopy fills and fruit appears — the visible overflow of a life abiding and bearing witness.',
  ),
  GrowthStage(
    id: StageId.forestBuilder,
    level: 4,
    name: 'Forest Builder',
    emoji: '🌲',
    image: 'assets/tree/stage-4-grove.png',
    verse: 'Go and make disciples of all nations. — Matthew 28:19',
    description:
        'Saplings rise in your shade. You are no longer only growing — you are helping others take root.',
  ),
  GrowthStage(
    id: StageId.forestOfNations,
    level: 5,
    name: 'Forest of Nations',
    emoji: '🌍',
    image: 'assets/tree/stage-5-forest.png',
    verse: 'The nations will walk by its light. — Revelation 21:24',
    description:
        'A whole grove flourishes. Generations of disciples now shelter, feed, and multiply one another.',
  ),
];

const List<TapZone> kTapZones = [
  TapZone(
    id: ZoneId.roots,
    label: 'Roots',
    theme: 'Prayer & the Word',
    metric: 'prayers',
    unit: 'prayers offered',
    description:
        'Time in prayer and Scripture that feeds everything unseen. Deep roots keep the tree standing through storms.',
    cx: 50,
    cy: 88,
    r: 20,
  ),
  TapZone(
    id: ZoneId.trunk,
    label: 'Trunk',
    theme: 'Consistency',
    metric: 'streakDays',
    unit: 'day rhythm in the Word',
    description:
        'The daily, faithful returning. Every rhythm of devotion adds another ring of strength to the trunk.',
    cx: 50,
    cy: 66,
    r: 13,
  ),
  TapZone(
    id: ZoneId.branches,
    label: 'Branches',
    theme: 'Mentoring',
    metric: 'disciples',
    unit: 'disciples walking with you',
    description:
        'Reaching outward to walk alongside others. Branches carry life from the trunk to where new growth forms.',
    cx: 27,
    cy: 42,
    r: 15,
  ),
  TapZone(
    id: ZoneId.canopy,
    label: 'Canopy',
    theme: 'Impact',
    metric: 'peersConnected',
    unit: 'peers reached in the network',
    description:
        'The shade and shelter your life provides. A full canopy is the visible reach of a maturing faith.',
    cx: 50,
    cy: 27,
    r: 22,
  ),
  TapZone(
    id: ZoneId.fruit,
    label: 'Fruit',
    theme: 'Milestones',
    metric: 'studiesCompleted',
    unit: 'studies completed together',
    description:
        'Answered prayers, changed lives, and completed seasons — the fruit that proves the tree is truly alive.',
    cx: 70,
    cy: 34,
    r: 12,
  ),
];

const List<int> kStageScoreThresholds = [0, 4, 12, 28, 60, 110];

GrowthStage getStage(int level) {
  final clamped = level.clamp(0, kGrowthStages.length - 1).toInt();
  return kGrowthStages[clamped];
}

int growthScore(GrowthMetrics m) {
  return m.studiesCompleted * 1 +
      m.disciples * 5 +
      m.nationsReached * 8 +
      (m.peersConnected * 0.5).floor() +
      (m.prayers / 5).floor() +
      (m.streakDays / 7).floor() * 2;
}

GrowthResult computeGrowth(GrowthMetrics m) {
  final score = growthScore(m);
  var level = 0;
  for (var i = 0; i < kStageScoreThresholds.length; i++) {
    if (score >= kStageScoreThresholds[i]) level = i;
  }
  final isMax = level >= kStageScoreThresholds.length - 1;
  final currentThreshold = kStageScoreThresholds[level];
  final nextThreshold =
      isMax ? currentThreshold : kStageScoreThresholds[level + 1];
  final span = (nextThreshold - currentThreshold).clamp(1, 999999).toInt();
  final progress = isMax
      ? 1.0
      : ((score - currentThreshold) / span).clamp(0.0, 1.0).toDouble();
  return GrowthResult(
    level: level,
    stage: kGrowthStages[level],
    score: score,
    progress: progress,
    isMax: isMax,
    nextThreshold: nextThreshold,
    toNext: isMax ? 0 : (nextThreshold - score).clamp(0, 999999).toInt(),
  );
}
