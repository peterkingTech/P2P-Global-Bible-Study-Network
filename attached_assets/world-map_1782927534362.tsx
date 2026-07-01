"use client"

import { useMemo, useState } from "react"
import { geoNaturalEarth1, geoPath } from "d3-geo"
import { feature } from "topojson-client"
import { cn } from "@/lib/utils"
import {
  DISCIPLES,
  mentorEdges,
  SEASON_THEME,
  type Disciple,
  type Season,
} from "./forest-data"
import worldTopo from "./countries-110m.json"

const W = 980
const H = 500
/** scale multiplier for each zoom level (Global → Individual) */
const ZOOM_K = [1, 2.2, 3.6, 6, 10]
const ZOOM_LABEL = ["Global", "Continent", "Country", "City", "Individual"]

export interface MapFilters {
  stages: Set<number>
  activity: "all" | "praying" | "recent"
  relationship: "all" | "disciples" | "mentors"
}

interface WorldMapProps {
  season: Season
  filters: MapFilters
  onHover?: (d: Disciple | null) => void
  className?: string
}

export function WorldMap({ season, filters, className }: WorldMapProps) {
  const theme = SEASON_THEME[season]

  // Project the world once.
  const { countryPaths, points } = useMemo(() => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const topo = worldTopo as any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const fc = feature(topo, topo.objects.countries) as any

    const projection = geoNaturalEarth1().fitSize([W, H], { type: "Sphere" })
    const path = geoPath(projection)

    const countryPaths = (fc.features as unknown[])
      .map((f) => path(f as never) ?? "")
      .filter(Boolean)

    const points = DISCIPLES.map((d) => {
      const xy = projection(d.coordinates)
      const [x, y] = xy ?? [0, 0]
      return { d, x, y, px: (x / W) * 100, py: (y / H) * 100 }
    })

    return { countryPaths, points }
  }, [])

  const pointById = useMemo(
    () => new Map(points.map((p) => [p.d.id, p])),
    [points],
  )

  const edges = useMemo(() => mentorEdges(), [])

  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [hoveredId, setHoveredId] = useState<string | null>(null)
  const [level, setLevel] = useState(0)

  // Which disciples pass the active filters.
  const isVisible = useMemo(() => {
    const map = new Map<string, boolean>()
    for (const { d } of points) {
      let ok = true
      if (filters.stages.size > 0 && !filters.stages.has(d.level)) ok = false
      if (filters.activity === "praying" && !d.praying) ok = false
      if (filters.activity === "recent") {
        const recent = /now|m ago|h ago/.test(d.lastActive)
        if (!recent) ok = false
      }
      if (filters.relationship === "disciples" && d.mentorId !== "you") ok = false
      if (filters.relationship === "mentors" && d.id !== "you") {
        // "mentors" view highlights the viewer's own upward chain; here the
        // viewer has none, so only the viewer node is emphasized.
        ok = d.id === "you"
      }
      map.set(d.id, ok)
    }
    return map
  }, [points, filters])

  const focal = selectedId ? pointById.get(selectedId) : undefined
  const k = ZOOM_K[level]
  const fx = focal ? focal.px : 50
  const fy = focal ? focal.py : 50

  function screenPct(px: number, py: number) {
    return { x: 50 + (px - fx) * k, y: 50 + (py - fy) * k }
  }

  function selectDisciple(id: string) {
    if (selectedId === id) {
      setSelectedId(null)
      setLevel(0)
      return
    }
    setSelectedId(id)
    setLevel((l) => Math.max(l, 2))
  }

  const activeId = hoveredId ?? selectedId
  const hovered = activeId ? pointById.get(activeId) : undefined

  return (
    <div
      className={cn(
        "relative isolate w-full overflow-hidden rounded-2xl border border-white/10",
        className,
      )}
      style={{ backgroundColor: theme.ocean }}
    >
      {/* Transformed geography layer (countries + connections) */}
      <div
        className="relative w-full transition-transform duration-700 ease-out"
        style={{
          aspectRatio: `${W} / ${H}`,
          transformOrigin: `${fx}% ${fy}%`,
          transform: `translate(${50 - fx}%, ${50 - fy}%) scale(${k})`,
        }}
      >
        <svg
          viewBox={`0 0 ${W} ${H}`}
          className="h-full w-full"
          role="img"
          aria-label="World map of disciples"
        >
          <defs>
            <radialGradient id="ocean-glow" cx="50%" cy="45%" r="65%">
              <stop offset="0%" stopColor={theme.land} stopOpacity="0.35" />
              <stop offset="100%" stopColor={theme.ocean} stopOpacity="0" />
            </radialGradient>
          </defs>
          <rect width={W} height={H} fill="url(#ocean-glow)" />

          {/* Countries */}
          <g>
            {countryPaths.map((dPath, i) => (
              <path
                key={i}
                d={dPath}
                fill={theme.land}
                stroke={theme.border}
                strokeWidth={0.4 / k}
                strokeLinejoin="round"
              />
            ))}
          </g>

          {/* Connection lines */}
          <g fill="none" strokeLinecap="round">
            {edges.map(({ from, to, covenant }, i) => {
              const a = pointById.get(from.id)
              const b = pointById.get(to.id)
              if (!a || !b) return null
              const visible =
                isVisible.get(from.id) && isVisible.get(to.id)
              const emphasized =
                activeId === from.id || activeId === to.id
              const mx = (a.x + b.x) / 2
              const my = (a.y + b.y) / 2 - Math.abs(a.x - b.x) * 0.12 - 12
              const stroke = covenant ? theme.accent : theme.node
              return (
                <path
                  key={i}
                  d={`M${a.x},${a.y} Q${mx},${my} ${b.x},${b.y}`}
                  stroke={stroke}
                  strokeWidth={(covenant ? 1.4 : 0.9) / k}
                  strokeOpacity={
                    !visible ? 0.05 : emphasized ? 0.95 : covenant ? 0.6 : 0.32
                  }
                  strokeDasharray={covenant ? undefined : `${3 / k} ${3 / k}`}
                />
              )
            })}
          </g>
        </svg>
      </div>

      {/* Node overlay (constant size, repositioned to match zoom) */}
      <div className="pointer-events-none absolute inset-0">
        {points.map((p) => {
          const { x, y } = screenPct(p.px, p.py)
          if (x < -5 || x > 105 || y < -5 || y > 105) return null
          const visible = isVisible.get(p.d.id) ?? true
          const isViewer = p.d.id === "you"
          const emphasized = activeId === p.d.id
          const size = 8 + p.d.level * 2.5
          return (
            <button
              key={p.d.id}
              type="button"
              onClick={() => selectDisciple(p.d.id)}
              onMouseEnter={() => setHoveredId(p.d.id)}
              onMouseLeave={() => setHoveredId(null)}
              onFocus={() => setHoveredId(p.d.id)}
              onBlur={() => setHoveredId(null)}
              aria-label={`${p.d.name}, ${p.d.city} — ${p.d.stage}`}
              className="pointer-events-auto absolute -translate-x-1/2 -translate-y-1/2 rounded-full outline-none focus-visible:ring-2 focus-visible:ring-white/70"
              style={{
                left: `${x}%`,
                top: `${y}%`,
                opacity: visible ? 1 : 0.18,
              }}
            >
              {/* Breathing glow */}
              <span
                className="animate-tree-glow pointer-events-none absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 rounded-full blur-[2px]"
                style={{
                  width: size * 2.4,
                  height: size * 2.4,
                  backgroundColor: theme.node,
                  opacity: emphasized ? 0.7 : 0.4,
                }}
              />
              {/* Praying halo */}
              {p.d.praying && (
                <span
                  className="pointer-events-none absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 rounded-full"
                  style={{
                    width: size * 1.7,
                    height: size * 1.7,
                    boxShadow: `0 0 0 1.5px ${theme.accent}`,
                    opacity: 0.6,
                  }}
                />
              )}
              {/* Core node */}
              <span
                className="pointer-events-none relative block rounded-full"
                style={{
                  width: size,
                  height: size,
                  backgroundColor: isViewer ? "#f4efe4" : theme.node,
                  boxShadow: `0 0 ${size / 1.5}px ${theme.node}, 0 0 2px ${theme.node}`,
                  border: isViewer ? `1.5px solid ${theme.accent}` : "none",
                }}
              />
            </button>
          )
        })}
      </div>

      {/* Hover / selection tooltip */}
      {hovered && (
        <Tooltip
          disciple={hovered.d}
          x={screenPct(hovered.px, hovered.py).x}
          y={screenPct(hovered.px, hovered.py).y}
        />
      )}

      {/* Zoom controls */}
      <div className="absolute bottom-3 left-3 flex items-center gap-2 rounded-full border border-white/10 bg-black/40 px-2 py-1.5 backdrop-blur">
        <button
          type="button"
          onClick={() => setLevel((l) => Math.max(0, l - 1))}
          disabled={level === 0}
          aria-label="Zoom out"
          className="flex size-6 items-center justify-center rounded-full text-[#9fe1cb] transition-colors hover:bg-white/10 disabled:opacity-30"
        >
          <span className="text-base leading-none">{"\u2212"}</span>
        </button>
        <span className="min-w-20 text-center text-[11px] font-medium tabular-nums text-[#9fe1cb]">
          {ZOOM_LABEL[level]}
        </span>
        <button
          type="button"
          onClick={() => setLevel((l) => Math.min(ZOOM_K.length - 1, l + 1))}
          disabled={level === ZOOM_K.length - 1}
          aria-label="Zoom in"
          className="flex size-6 items-center justify-center rounded-full text-[#9fe1cb] transition-colors hover:bg-white/10 disabled:opacity-30"
        >
          <span className="text-base leading-none">+</span>
        </button>
      </div>

      {selectedId && (
        <button
          type="button"
          onClick={() => {
            setSelectedId(null)
            setLevel(0)
          }}
          className="absolute bottom-3 right-3 rounded-full border border-white/10 bg-black/40 px-3 py-1.5 text-[11px] font-medium text-[#9fe1cb] backdrop-blur transition-colors hover:bg-white/10"
        >
          Reset view
        </button>
      )}
    </div>
  )
}

function Tooltip({
  disciple,
  x,
  y,
}: {
  disciple: Disciple
  x: number
  y: number
}) {
  const clampedX = Math.min(Math.max(x, 12), 88)
  const above = y > 55
  return (
    <div
      className="pointer-events-none absolute z-20 w-52 -translate-x-1/2 rounded-xl border border-white/10 bg-[#0b1512]/95 p-3 text-left shadow-xl backdrop-blur"
      style={{
        left: `${clampedX}%`,
        top: `${y}%`,
        transform: `translate(-50%, ${above ? "-115%" : "15%"})`,
      }}
    >
      <p className="text-sm font-semibold text-[#f4efe4]">{disciple.name}</p>
      <p className="text-xs text-[#9fe1cb]/80">
        {disciple.city}, {disciple.country}
      </p>
      <div className="mt-2 flex items-center justify-between text-[11px]">
        <span className="rounded-full bg-[#1d9e75]/20 px-2 py-0.5 capitalize text-[#9fe1cb]">
          {disciple.stage.replace(/-/g, " ")}
        </span>
        <span className="text-[#c9b98f]">{disciple.lastActive}</span>
      </div>
      {disciple.praying && (
        <p className="mt-2 text-[11px] text-[#f7c948]">Praying now</p>
      )}
    </div>
  )
}
