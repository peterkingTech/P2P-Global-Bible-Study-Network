"use client"

import { useState } from "react"
import Image from "next/image"
import { cn } from "@/lib/utils"
import {
  GROWTH_STAGES,
  TAP_ZONES,
  computeGrowth,
  getStage,
  type GrowthMetrics,
  type GrowthResult,
  type StageId,
  type ZoneId,
} from "./tree-data"

interface LivingTreeProps {
  /**
   * Current growth stage — either the id or the 0-5 level index.
   * Ignored when `metrics` is supplied (the stage is derived from activity).
   */
  stage?: StageId | number
  /**
   * Real P2P network activity. When provided, the tree grows itself from
   * this data and shows progress toward the next stage.
   */
  metrics?: GrowthMetrics
  /** `full` for the profile view, `mini` for list rows and cards. */
  variant?: "full" | "mini"
  /** Called when a tap zone is selected (full variant only). */
  onZoneSelect?: (zone: ZoneId) => void
  className?: string
}

/** Resolve either explicit stage or derived-from-metrics into a common shape. */
function resolveGrowth(
  stage: StageId | number | undefined,
  metrics: GrowthMetrics | undefined,
): { level: number; growth: GrowthResult | null } {
  if (metrics) {
    const growth = computeGrowth(metrics)
    return { level: growth.level, growth }
  }
  return { level: getStage(stage ?? 0).level, growth: null }
}

export function LivingTree(props: LivingTreeProps) {
  const { stage, metrics, variant = "full", onZoneSelect, className } = props
  const { level, growth } = resolveGrowth(stage, metrics)

  if (variant === "mini") {
    return <MiniTree level={level} className={className} />
  }

  return (
    <FullTree
      level={level}
      metrics={metrics}
      growth={growth}
      onZoneSelect={onZoneSelect}
      className={className}
    />
  )
}

/* -------------------------------------------------------------------- */
/* Mini — for lists, leaderboards, and compact cards                    */
/* -------------------------------------------------------------------- */

function MiniTree({ level, className }: { level: number; className?: string }) {
  const current = getStage(level)
  return (
    <div
      className={cn(
        "relative inline-flex size-14 shrink-0 items-center justify-center overflow-hidden rounded-full",
        "ring-1 ring-[#e3d9c2]",
        className,
      )}
      role="img"
      aria-label={`Growth stage: ${current.name}`}
      title={`${current.emoji} ${current.name}`}
    >
      <Image
        src={current.image || "/placeholder.svg"}
        alt=""
        fill
        sizes="56px"
        className="animate-tree-breathe object-cover"
      />
      {/* soft living sheen */}
      <span className="animate-tree-glow pointer-events-none absolute inset-0 rounded-full bg-gradient-to-t from-[#0f6e56]/25 to-transparent" />
      <span
        aria-hidden="true"
        className="absolute bottom-0.5 right-0.5 text-[10px] leading-none drop-shadow"
      >
        {current.emoji}
      </span>
    </div>
  )
}

/* -------------------------------------------------------------------- */
/* Full — for the profile / dashboard view                             */
/* -------------------------------------------------------------------- */

function FullTree({
  level,
  metrics,
  growth,
  onZoneSelect,
  className,
}: {
  level: number
  metrics?: GrowthMetrics
  growth: GrowthResult | null
  onZoneSelect?: (zone: ZoneId) => void
  className?: string
}) {
  const [activeZone, setActiveZone] = useState<ZoneId | null>(null)
  const current = getStage(level)
  const active = TAP_ZONES.find((z) => z.id === activeZone) ?? null
  const nextStage = growth && !growth.isMax ? GROWTH_STAGES[level + 1] : null

  function selectZone(id: ZoneId) {
    setActiveZone((prev) => (prev === id ? null : id))
    onZoneSelect?.(id)
  }

  return (
    <section
      className={cn(
        "mx-auto w-full max-w-md overflow-hidden rounded-3xl border border-[#e3d9c2]",
        "bg-gradient-to-b from-[#f7f2e7] to-[#efe7d3] shadow-sm",
        className,
      )}
      aria-label={`Living Tree — ${current.name}`}
    >
      {/* Stage header */}
      <header className="flex items-center justify-between px-6 pt-6">
        <div>
          <p className="text-xs font-medium uppercase tracking-widest text-[#ba7517]">
            {`Stage ${current.level + 1} of ${GROWTH_STAGES.length}`}
          </p>
          <h2 className="flex items-center gap-2 text-pretty text-xl font-semibold text-[#0f6e56]">
            <span aria-hidden="true" className="text-2xl leading-none">
              {current.emoji}
            </span>
            {current.name}
          </h2>
        </div>
        <StageDots level={current.level} />
      </header>

      {/* Growth toward the next stage — only when driven by real activity */}
      {growth && (
        <div className="px-6 pt-4">
          <div className="flex items-center justify-between text-xs">
            <span className="font-medium text-[#6b5c3d]">
              {nextStage
                ? `Growing toward ${nextStage.emoji} ${nextStage.name}`
                : "Fully grown — a forest of nations"}
            </span>
            <span className="font-semibold text-[#0f6e56]">
              {Math.round(growth.progress * 100)}%
            </span>
          </div>
          <div
            className="mt-1.5 h-2 overflow-hidden rounded-full bg-[#e3d9c2]"
            role="progressbar"
            aria-valuenow={Math.round(growth.progress * 100)}
            aria-valuemin={0}
            aria-valuemax={100}
            aria-label="Progress to next growth stage"
          >
            <div
              className="h-full rounded-full bg-gradient-to-r from-[#1d9e75] to-[#9fe1cb] transition-[width] duration-700 ease-out"
              style={{ width: `${Math.max(4, growth.progress * 100)}%` }}
            />
          </div>
          {nextStage && (
            <p className="mt-1.5 text-[11px] text-[#8a7b5c]">
              {`${growth.toNext} more points of shared study, prayer, and mentoring to grow again.`}
            </p>
          )}
        </div>
      )}

      {/* The tree stage — photorealistic image */}
      <div className="relative mx-auto mt-4 aspect-square w-full max-w-[380px] overflow-hidden rounded-2xl border border-[#e3d9c2]">
        <Image
          key={current.id}
          src={current.image || "/placeholder.svg"}
          alt={`${current.name} — ${current.description}`}
          fill
          priority
          sizes="(max-width: 480px) 90vw, 380px"
          className="animate-tree-breathe object-cover"
        />

        {/* Sunlit ambient glow that gently breathes — makes it feel alive */}
        <span className="animate-tree-glow pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_35%_25%,rgba(255,244,214,0.5),transparent_55%)]" />
        {/* Gentle vignette for depth */}
        <span className="pointer-events-none absolute inset-0 bg-gradient-to-t from-[#1a2e10]/25 via-transparent to-transparent" />

        {/* Interactive tap zones */}
        {TAP_ZONES.map((zone) => {
          const isActive = activeZone === zone.id
          return (
            <button
              key={zone.id}
              type="button"
              onClick={() => selectZone(zone.id)}
              aria-pressed={isActive}
              aria-label={`${zone.label}: ${zone.theme}`}
              className={cn(
                "group absolute -translate-x-1/2 -translate-y-1/2 rounded-full",
                "transition-transform duration-300 focus:outline-none focus-visible:ring-2 focus-visible:ring-[#ffe9b0]",
                "hover:scale-105 active:scale-95",
              )}
              style={{
                left: `${zone.hotspot.cx}%`,
                top: `${zone.hotspot.cy}%`,
                width: `${zone.hotspot.r * 2}%`,
                aspectRatio: "1",
              }}
            >
              {/* Hit target + subtle resting halo */}
              <span
                className={cn(
                  "absolute inset-0 rounded-full transition-opacity duration-300",
                  isActive
                    ? "bg-[#ffe9b0]/35 opacity-100"
                    : "bg-[#ffe9b0]/0 opacity-0 group-hover:bg-[#ffe9b0]/25 group-hover:opacity-100",
                )}
              />
              {/* Pulsing ring while active */}
              {isActive && (
                <span className="animate-zone-ring absolute inset-0 rounded-full ring-2 ring-[#ffe9b0]" />
              )}
              {/* Zone dot marker */}
              <span
                className={cn(
                  "absolute left-1/2 top-1/2 size-2.5 -translate-x-1/2 -translate-y-1/2 rounded-full ring-2 ring-black/20 transition-colors",
                  isActive
                    ? "bg-[#ffe9b0]"
                    : "bg-white/70 group-hover:bg-[#ffe9b0]",
                )}
              />
              <span className="sr-only">{zone.description}</span>
            </button>
          )
        })}

        {/* Stage caption chip */}
        <div className="pointer-events-none absolute bottom-3 left-3 flex items-center gap-1.5 rounded-full bg-black/45 px-3 py-1 text-xs font-medium text-white backdrop-blur-sm">
          <span aria-hidden="true">{current.emoji}</span>
          {current.name}
        </div>
      </div>

      {/* Info panel — verse when idle, zone detail when a zone is tapped */}
      <div className="min-h-[132px] border-t border-[#e3d9c2] bg-[#fbf7ee]/70 px-6 py-5">
        {active ? (
          <article key={active.id} className="animate-fruit-pop">
            <div className="flex items-center gap-2">
              <span className="inline-block size-2 rounded-full bg-[#1d9e75]" />
              <h3 className="text-sm font-semibold text-[#0f6e56]">
                {active.label}
              </h3>
              <span className="text-xs font-medium text-[#ba7517]">
                {active.theme}
              </span>
            </div>
            {metrics && (
              <p className="mt-2 flex items-baseline gap-1.5">
                <span className="text-2xl font-semibold tabular-nums text-[#0f6e56]">
                  {metrics[active.metric]}
                </span>
                <span className="text-xs text-[#8a7b5c]">{active.unit}</span>
              </p>
            )}
            <p className="mt-2 text-pretty text-sm leading-relaxed text-[#4a3a1e]">
              {active.description}
            </p>
            <button
              type="button"
              onClick={() => setActiveZone(null)}
              className="mt-3 text-xs font-medium text-[#0f6e56] underline-offset-2 hover:underline"
            >
              Back to reflection
            </button>
          </article>
        ) : (
          <div>
            <p className="text-pretty text-sm leading-relaxed text-[#4a3a1e]">
              {current.description}
            </p>
            <p className="mt-3 border-l-2 border-[#ba7517] pl-3 text-sm italic leading-relaxed text-[#633806]">
              {current.verse}
            </p>
            <p className="mt-3 text-xs text-[#8a7b5c]">
              Tap the roots, trunk, branches, canopy, or fruit to see the
              activity feeding your growth.
            </p>
          </div>
        )}
      </div>
    </section>
  )
}

function StageDots({ level }: { level: number }) {
  return (
    <div className="flex items-center gap-1.5" aria-hidden="true">
      {GROWTH_STAGES.map((s) => (
        <span
          key={s.id}
          className={cn(
            "size-2 rounded-full transition-colors",
            s.level < level && "bg-[#1d9e75]",
            s.level === level && "bg-[#ba7517] ring-2 ring-[#ba7517]/25",
            s.level > level && "bg-[#d8cdb2]",
          )}
        />
      ))}
    </div>
  )
}
