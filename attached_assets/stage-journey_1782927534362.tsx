"use client"

import Image from "next/image"
import {
  GROWTH_STAGES,
  STAGE_SCORE_THRESHOLDS,
  computeGrowth,
  type GrowthMetrics,
} from "@/components/living-tree/tree-data"
import { cn } from "@/lib/utils"

/**
 * The full six-stage growth ladder for the P2P Global Bible Study Network.
 * Each stage shows its emoji, name, Scripture, and explanation, and is marked
 * as completed, the current stage, or still locked — with the score needed to
 * unlock it — so the believer can see the whole discipleship journey at once.
 */
export function StageJourney({ metrics }: { metrics: GrowthMetrics }) {
  const growth = computeGrowth(metrics)

  return (
    <section aria-label="Growth stages" className="mt-12">
      <div className="text-center">
        <p className="text-xs font-medium uppercase tracking-[0.2em] text-[#ba7517]">
          The Six Stages of Growth
        </p>
        <h2 className="mt-2 text-balance text-2xl font-semibold text-[#0f6e56]">
          From a Dormant Seed to a Forest of Nations
        </h2>
        <p className="mx-auto mt-2 max-w-lg text-pretty text-sm leading-relaxed text-[#6b5c3d]">
          Every disciple walks the same path. Your activity in the network moves
          you from one stage to the next — and each stage shelters more life
          than the last.
        </p>
      </div>

      <ol className="mt-8 space-y-4">
        {GROWTH_STAGES.map((stage) => {
          const isDone = stage.level < growth.level
          const isCurrent = stage.level === growth.level
          const isLocked = stage.level > growth.level
          const threshold = STAGE_SCORE_THRESHOLDS[stage.level]

          return (
            <li
              key={stage.id}
              className={cn(
                "relative flex gap-4 rounded-2xl border p-4 transition-colors",
                isCurrent &&
                  "border-[#1d9e75] bg-[#eefaf4] shadow-[0_0_0_1px_rgba(29,158,117,0.25)]",
                isDone && "border-[#e3d9c2] bg-[#fbf7ee]",
                isLocked && "border-[#e7e0d0] bg-[#f6f2e8]",
              )}
            >
              {/* Stage image */}
              <div
                className={cn(
                  "relative h-20 w-20 shrink-0 overflow-hidden rounded-xl border border-[#e3d9c2]",
                  isLocked && "grayscale",
                )}
              >
                <Image
                  src={stage.image || "/placeholder.svg"}
                  alt={stage.name}
                  fill
                  sizes="80px"
                  className="object-cover"
                />
                {isLocked && (
                  <div className="absolute inset-0 bg-[#442604]/30" aria-hidden />
                )}
              </div>

              {/* Details */}
              <div className="min-w-0 flex-1">
                <div className="flex flex-wrap items-center gap-2">
                  <span className="text-lg leading-none" aria-hidden>
                    {stage.emoji}
                  </span>
                  <h3
                    className={cn(
                      "text-base font-semibold",
                      isLocked ? "text-[#8a7b5c]" : "text-[#0f6e56]",
                    )}
                  >
                    {stage.name}
                  </h3>
                  <StageBadge
                    isDone={isDone}
                    isCurrent={isCurrent}
                    isLocked={isLocked}
                  />
                </div>

                <p className="mt-1 text-sm leading-relaxed text-[#4a3a1e]">
                  {stage.description}
                </p>
                <p className="mt-1 text-xs italic text-[#ba7517]">
                  {stage.verse}
                </p>

                {/* Current-stage progress toward next */}
                {isCurrent && !growth.isMax && (
                  <div className="mt-3">
                    <div className="h-2 overflow-hidden rounded-full bg-[#dfeee7]">
                      <div
                        className="h-full rounded-full bg-[#1d9e75] transition-[width] duration-700"
                        style={{ width: `${Math.round(growth.progress * 100)}%` }}
                      />
                    </div>
                    <p className="mt-1 text-[11px] text-[#6b5c3d]">
                      {growth.toNext} more growth points to reach{" "}
                      {GROWTH_STAGES[growth.level + 1].emoji}{" "}
                      {GROWTH_STAGES[growth.level + 1].name}
                    </p>
                  </div>
                )}

                {isLocked && (
                  <p className="mt-2 text-[11px] font-medium text-[#8a7b5c]">
                    Unlocks at {threshold} growth points
                  </p>
                )}
              </div>
            </li>
          )
        })}
      </ol>
    </section>
  )
}

function StageBadge({
  isDone,
  isCurrent,
  isLocked,
}: {
  isDone: boolean
  isCurrent: boolean
  isLocked: boolean
}) {
  if (isCurrent) {
    return (
      <span className="rounded-full bg-[#1d9e75] px-2 py-0.5 text-[11px] font-semibold text-[#f4efe4]">
        You are here
      </span>
    )
  }
  if (isDone) {
    return (
      <span className="rounded-full bg-[#0f6e56]/10 px-2 py-0.5 text-[11px] font-semibold text-[#0f6e56]">
        Reached
      </span>
    )
  }
  if (isLocked) {
    return (
      <span className="rounded-full bg-[#e7e0d0] px-2 py-0.5 text-[11px] font-semibold text-[#8a7b5c]">
        Locked
      </span>
    )
  }
  return null
}
