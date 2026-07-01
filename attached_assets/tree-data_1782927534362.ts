/**
 * Data model for the Living Tree discipleship widget.
 *
 * A believer's journey is expressed across six organic stages of growth.
 * Each stage unlocks more of the tree — deeper roots, a stronger trunk,
 * wider branches, a fuller canopy, and eventually fruit that is shared
 * with others.
 */

export type StageId =
  | "dormant-seed"
  | "sprout"
  | "young-tree"
  | "fruitful-tree"
  | "forest-builder"
  | "forest-of-nations"

export type ZoneId = "roots" | "trunk" | "branches" | "canopy" | "fruit"

export interface GrowthStage {
  id: StageId
  /** 0-5 growth index, used to drive the visual rendering. */
  level: number
  name: string
  /** Emoji marker shown alongside the stage name. */
  emoji: string
  /** Photorealistic image representing this stage of growth. */
  image: string
  /** Short spiritual descriptor shown in the UI. */
  verse: string
  description: string
}

export interface TapZone {
  id: ZoneId
  label: string
  /** The discipleship theme this zone represents. */
  theme: string
  description: string
  /** The P2P network metric this zone draws its life from. */
  metric: keyof GrowthMetrics
  /** How that metric reads in the panel, e.g. "prayers offered". */
  unit: string
  /**
   * Position of the zone hotspot as percentages of the widget box.
   * cx/cy are the center, r is the radius (as % of width).
   */
  hotspot: { cx: number; cy: number; r: number }
}

/**
 * Real activity from the P2P Global Bible Study Network that feeds the tree.
 * The believer's tree grows from what actually happens in the community —
 * studies shared, peers connected, disciples raised, prayers offered, and
 * the steady rhythm of returning to the Word.
 */
export interface GrowthMetrics {
  /** Peer-to-peer Bible study sessions completed together. */
  studiesCompleted: number
  /** Believers linked with you in the network. */
  peersConnected: number
  /** People you are actively mentoring / discipling. */
  disciples: number
  /** Prayers offered and logged in the Upper Room. */
  prayers: number
  /** Consecutive days spent in the Word. */
  streakDays: number
  /** Nations your branch of the network has reached. */
  nationsReached: number
}

export const GROWTH_STAGES: GrowthStage[] = [
  {
    id: "dormant-seed",
    level: 0,
    name: "Dormant Seed",
    emoji: "🌰",
    image: "/tree/stage-0-seed.png",
    verse: "Unless a seed falls to the ground and dies… — John 12:24",
    description:
      "The journey begins in stillness. A seed rests in the soil, holding the promise of everything to come.",
  },
  {
    id: "sprout",
    level: 1,
    name: "Sprout",
    emoji: "🌱",
    image: "/tree/stage-1-sprout.png",
    verse: "He is like a tree planted by streams of water. — Psalm 1:3",
    description:
      "First light. Tender shoots break the surface as new habits of prayer and Scripture take hold.",
  },
  {
    id: "young-tree",
    level: 2,
    name: "Young Tree",
    emoji: "🌿",
    image: "/tree/stage-2-young.png",
    verse: "Rooted and built up in Him. — Colossians 2:7",
    description:
      "A trunk forms and branches reach outward. Consistency is turning belief into a settled root system.",
  },
  {
    id: "fruitful-tree",
    level: 3,
    name: "Fruitful Tree",
    emoji: "🌳",
    image: "/tree/stage-3-fruitful.png",
    verse: "By their fruit you will recognize them. — Matthew 7:20",
    description:
      "The canopy fills and fruit appears — the visible overflow of a life abiding and bearing witness.",
  },
  {
    id: "forest-builder",
    level: 4,
    name: "Forest Builder",
    emoji: "🌲",
    image: "/tree/stage-4-grove.png",
    verse: "Go and make disciples of all nations. — Matthew 28:19",
    description:
      "Saplings rise in your shade. You are no longer only growing — you are helping others take root.",
  },
  {
    id: "forest-of-nations",
    level: 5,
    name: "Forest of Nations",
    emoji: "🌍",
    image: "/tree/stage-5-forest.png",
    verse: "The nations will walk by its light. — Revelation 21:24",
    description:
      "A whole grove flourishes. Generations of disciples now shelter, feed, and multiply one another.",
  },
]

export const TAP_ZONES: TapZone[] = [
  {
    id: "roots",
    label: "Roots",
    theme: "Prayer & the Word",
    metric: "prayers",
    unit: "prayers offered",
    description:
      "Time in prayer and Scripture that feeds everything unseen. Deep roots keep the tree standing through storms.",
    hotspot: { cx: 50, cy: 88, r: 20 },
  },
  {
    id: "trunk",
    label: "Trunk",
    theme: "Consistency",
    metric: "streakDays",
    unit: "day rhythm in the Word",
    description:
      "The daily, faithful returning. Every rhythm of devotion adds another ring of strength to the trunk.",
    hotspot: { cx: 50, cy: 66, r: 13 },
  },
  {
    id: "branches",
    label: "Branches",
    theme: "Mentoring",
    metric: "disciples",
    unit: "disciples walking with you",
    description:
      "Reaching outward to walk alongside others. Branches carry life from the trunk to where new growth forms.",
    hotspot: { cx: 27, cy: 42, r: 15 },
  },
  {
    id: "canopy",
    label: "Canopy",
    theme: "Impact",
    metric: "peersConnected",
    unit: "peers reached in the network",
    description:
      "The shade and shelter your life provides. A full canopy is the visible reach of a maturing faith.",
    hotspot: { cx: 50, cy: 27, r: 22 },
  },
  {
    id: "fruit",
    label: "Fruit",
    theme: "Milestones",
    metric: "studiesCompleted",
    unit: "studies completed together",
    description:
      "Answered prayers, changed lives, and completed seasons — the fruit that proves the tree is truly alive.",
    hotspot: { cx: 70, cy: 34, r: 12 },
  },
]

export function getStage(input: StageId | number): GrowthStage {
  if (typeof input === "number") {
    const clamped = Math.max(0, Math.min(GROWTH_STAGES.length - 1, Math.round(input)))
    return GROWTH_STAGES[clamped]
  }
  return GROWTH_STAGES.find((s) => s.id === input) ?? GROWTH_STAGES[0]
}

export function getZone(id: ZoneId): TapZone {
  return TAP_ZONES.find((z) => z.id === id) ?? TAP_ZONES[0]
}

/**
 * A composite "life score" derived from real network activity. Mentoring and
 * reaching nations are weighted most heavily — in a discipleship network,
 * multiplying others matters more than personal accumulation.
 */
export function growthScore(m: GrowthMetrics): number {
  return (
    m.studiesCompleted * 1 +
    m.disciples * 5 +
    m.nationsReached * 8 +
    m.peersConnected * 0.5 +
    Math.floor(m.prayers / 5) +
    Math.floor(m.streakDays / 7) * 2
  )
}

/** Cumulative score needed to enter each of the six stages. */
export const STAGE_SCORE_THRESHOLDS = [0, 4, 12, 28, 60, 110]

export interface GrowthResult {
  level: number
  stage: GrowthStage
  score: number
  /** 0-1 progress from the current stage toward the next. */
  progress: number
  isMax: boolean
  /** Score required to reach the next stage (equals current at max). */
  nextThreshold: number
  /** Points still needed to reach the next stage. */
  toNext: number
}

/** Translate raw network activity into a stage + progress toward the next. */
export function computeGrowth(m: GrowthMetrics): GrowthResult {
  const score = growthScore(m)
  let level = 0
  for (let i = 0; i < STAGE_SCORE_THRESHOLDS.length; i++) {
    if (score >= STAGE_SCORE_THRESHOLDS[i]) level = i
  }
  const isMax = level >= STAGE_SCORE_THRESHOLDS.length - 1
  const currentThreshold = STAGE_SCORE_THRESHOLDS[level]
  const nextThreshold = isMax
    ? currentThreshold
    : STAGE_SCORE_THRESHOLDS[level + 1]
  const span = Math.max(1, nextThreshold - currentThreshold)
  const progress = isMax
    ? 1
    : Math.min(1, Math.max(0, (score - currentThreshold) / span))
  return {
    level,
    stage: GROWTH_STAGES[level],
    score,
    progress,
    isMax,
    nextThreshold,
    toNext: isMax ? 0 : Math.max(0, Math.ceil(nextThreshold - score)),
  }
}

export function getMetricValue(m: GrowthMetrics, zone: TapZone): number {
  return m[zone.metric]
}
