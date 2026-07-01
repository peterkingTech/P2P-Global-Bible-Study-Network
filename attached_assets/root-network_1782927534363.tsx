import { cn } from "@/lib/utils"

/**
 * A quiet, glowing underground root network. Purely atmospheric —
 * it represents the hidden, connected prayers beneath the surface.
 */
export function RootNetwork({ className }: { className?: string }) {
  const roots = [
    "M300 0 C300 40 300 60 300 90 C300 130 220 150 180 190 C150 220 140 260 130 300",
    "M300 90 C300 130 380 150 420 190 C450 220 460 260 470 300",
    "M300 120 C300 150 260 170 250 210 C242 245 250 275 250 300",
    "M300 120 C300 150 345 170 355 210 C363 245 356 275 356 300",
    "M180 190 C150 205 120 215 90 240 C70 258 60 280 55 300",
    "M420 190 C450 205 480 215 510 240 C530 258 540 280 545 300",
    "M250 210 C230 235 210 250 200 300",
    "M355 210 C375 235 395 250 405 300",
  ]
  const nodes = [
    [300, 90],
    [180, 190],
    [420, 190],
    [250, 210],
    [355, 210],
    [90, 240],
    [510, 240],
    [130, 300],
    [470, 300],
    [250, 300],
    [356, 300],
  ] as const

  return (
    <svg
      viewBox="0 0 600 300"
      preserveAspectRatio="xMidYMax slice"
      className={cn("h-full w-full", className)}
      aria-hidden="true"
    >
      <defs>
        <linearGradient id="root-fade" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#e0a441" stopOpacity="0.55" />
          <stop offset="100%" stopColor="#7a4d12" stopOpacity="0.08" />
        </linearGradient>
        <radialGradient id="root-node" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stopColor="#f2c463" stopOpacity="0.9" />
          <stop offset="100%" stopColor="#e0a441" stopOpacity="0" />
        </radialGradient>
      </defs>

      {/* soft glow underlay */}
      <g className="animate-tree-glow" style={{ transformOrigin: "300px 150px" }}>
        {roots.map((d, i) => (
          <path
            key={`glow-${i}`}
            d={d}
            fill="none"
            stroke="#e0a441"
            strokeWidth={4}
            strokeOpacity={0.12}
            strokeLinecap="round"
            style={{ filter: "blur(3px)" }}
          />
        ))}
      </g>

      {/* crisp roots */}
      {roots.map((d, i) => (
        <path
          key={i}
          d={d}
          fill="none"
          stroke="url(#root-fade)"
          strokeWidth={1.4}
          strokeLinecap="round"
        />
      ))}

      {/* glowing junction nodes */}
      {nodes.map(([cx, cy], i) => (
        <g key={i}>
          <circle cx={cx} cy={cy} r={10} fill="url(#root-node)" />
          <circle
            cx={cx}
            cy={cy}
            r={1.6}
            fill="#f7d98a"
            className="animate-tree-glow"
            style={{ transformOrigin: `${cx}px ${cy}px`, animationDelay: `${i * 0.4}s` }}
          />
        </g>
      ))}
    </svg>
  )
}
