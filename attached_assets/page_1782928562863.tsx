"use client"

import { useState } from "react"
import { WorldMap, type MapFilters } from "@/components/forest/world-map"
import {
  GLOBAL_STATS,
  SEASON_THEME,
  type Season,
} from "@/components/forest/forest-data"
import { GROWTH_STAGES } from "@/components/living-tree/tree-data"
import { cn } from "@/lib/utils"

const SEASONS: Season[] = ["spring", "summer", "autumn", "winter"]

const ACTIVITY: { id: MapFilters["activity"]; label: string }[] = [
  { id: "all", label: "All" },
  { id: "praying", label: "Praying now" },
  { id: "recent", label: "Recently active" },
]

const RELATIONSHIP: { id: MapFilters["relationship"]; label: string }[] = [
  { id: "all", label: "Everyone" },
  { id: "disciples", label: "My disciples" },
  { id: "mentors", label: "Just me" },
]

export default function ForestPage() {
  const [season, setSeason] = useState<Season>("summer")
  const [stages, setStages] = useState<Set<number>>(new Set())
  const [activity, setActivity] = useState<MapFilters["activity"]>("all")
  const [relationship, setRelationship] =
    useState<MapFilters["relationship"]>("all")

  const theme = SEASON_THEME[season]

  function toggleStage(level: number) {
    setStages((prev) => {
      const next = new Set(prev)
      if (next.has(level)) next.delete(level)
      else next.add(level)
      return next
    })
  }

  return (
    <main className="min-h-screen bg-[#06110d] px-4 py-8 text-[#e8efe9]">
      <div className="mx-auto max-w-6xl">
        <header className="text-center">
          <p className="text-xs font-medium uppercase tracking-[0.25em] text-[#1d9e75]">
            The Global Forest
          </p>
          <h1 className="mt-2 text-balance text-3xl font-semibold text-[#f4efe4]">
            One Church, Many Nations
          </h1>
          <p className="mx-auto mt-3 max-w-lg text-pretty text-sm leading-relaxed text-[#9fe1cb]/70">
            {theme.caption}
          </p>
        </header>

        {/* Stats overlay */}
        <dl className="mx-auto mt-8 grid max-w-3xl grid-cols-2 gap-3 sm:grid-cols-4">
          {GLOBAL_STATS.map((s) => (
            <div
              key={s.label}
              className="rounded-2xl border border-white/10 bg-white/[0.03] px-4 py-3 text-center"
            >
              <dt className="sr-only">{s.label}</dt>
              <dd>
                <span className="block text-2xl font-semibold tabular-nums text-[#f7c948]">
                  {s.value}
                </span>
                <span className="mt-1 block text-[11px] uppercase tracking-wide text-[#9fe1cb]/60">
                  {s.label}
                </span>
              </dd>
            </div>
          ))}
        </dl>

        {/* Filter controls */}
        <div className="mt-8 flex flex-col gap-4 rounded-2xl border border-white/10 bg-white/[0.02] p-4 lg:flex-row lg:flex-wrap lg:items-end lg:justify-between">
          <FilterGroup label="Season">
            {SEASONS.map((s) => (
              <Chip
                key={s}
                active={season === s}
                onClick={() => setSeason(s)}
              >
                {SEASON_THEME[s].label.split(" — ")[0]}
              </Chip>
            ))}
          </FilterGroup>

          <FilterGroup label="Growth stage">
            {GROWTH_STAGES.map((s) => (
              <Chip
                key={s.id}
                active={stages.has(s.level)}
                onClick={() => toggleStage(s.level)}
              >
                {s.name}
              </Chip>
            ))}
          </FilterGroup>

          <FilterGroup label="Activity">
            {ACTIVITY.map((a) => (
              <Chip
                key={a.id}
                active={activity === a.id}
                onClick={() => setActivity(a.id)}
              >
                {a.label}
              </Chip>
            ))}
          </FilterGroup>

          <FilterGroup label="Relationship">
            {RELATIONSHIP.map((r) => (
              <Chip
                key={r.id}
                active={relationship === r.id}
                onClick={() => setRelationship(r.id)}
              >
                {r.label}
              </Chip>
            ))}
          </FilterGroup>
        </div>

        {/* Map */}
        <div className="mt-6">
          <WorldMap
            season={season}
            filters={{ stages, activity, relationship }}
          />
        </div>

        {/* Legend */}
        <div className="mt-4 flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-xs text-[#9fe1cb]/70">
          <LegendItem>
            <span
              className="inline-block size-2.5 rounded-full"
              style={{ backgroundColor: theme.node }}
            />
            Disciple tree
          </LegendItem>
          <LegendItem>
            <span
              className="inline-block h-0.5 w-6 rounded-full"
              style={{ backgroundColor: theme.accent }}
            />
            Paul–Timothy covenant
          </LegendItem>
          <LegendItem>
            <span
              className="inline-block h-0.5 w-6 rounded-full border-t border-dashed"
              style={{ borderColor: theme.node }}
            />
            Mentoring link
          </LegendItem>
          <LegendItem>
            <span
              className="inline-block size-2.5 rounded-full ring-1"
              style={{ boxShadow: `0 0 0 1.5px ${theme.accent}` }}
            />
            Praying now
          </LegendItem>
        </div>
      </div>
    </main>
  )
}

function FilterGroup({
  label,
  children,
}: {
  label: string
  children: React.ReactNode
}) {
  return (
    <div>
      <p className="mb-2 text-[11px] font-medium uppercase tracking-wider text-[#9fe1cb]/50">
        {label}
      </p>
      <div className="flex flex-wrap gap-1.5">{children}</div>
    </div>
  )
}

function Chip({
  active,
  onClick,
  children,
}: {
  active: boolean
  onClick: () => void
  children: React.ReactNode
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={active}
      className={cn(
        "rounded-full px-3 py-1 text-xs font-medium transition-colors",
        active
          ? "bg-[#1d9e75] text-[#06110d]"
          : "bg-white/5 text-[#9fe1cb]/80 hover:bg-white/10",
      )}
    >
      {children}
    </button>
  )
}

function LegendItem({ children }: { children: React.ReactNode }) {
  return <span className="inline-flex items-center gap-2">{children}</span>
}
