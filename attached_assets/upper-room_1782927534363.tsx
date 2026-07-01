"use client"

import { useEffect, useRef, useState } from "react"
import { Play, Pause, Mic, Send, Users } from "lucide-react"
import { cn } from "@/lib/utils"
import { RootNetwork } from "./root-network"

interface PrayerRoom {
  id: string
  nation: string
  language: string
  present: number
}

const ROOMS: PrayerRoom[] = [
  { id: "ng", nation: "Nigeria", language: "English · Yoruba", present: 42 },
  { id: "kr", nation: "South Korea", language: "Korean", present: 31 },
  { id: "br", nation: "Brazil", language: "Português", present: 28 },
  { id: "in", nation: "India", language: "Hindi · Tamil", present: 55 },
  { id: "ke", nation: "Kenya", language: "Swahili · English", present: 19 },
  { id: "de", nation: "Germany", language: "Deutsch", present: 12 },
]

interface WallRequest {
  id: number
  nation: string
  text: string
  when: string
}

const INITIAL_WALL: WallRequest[] = [
  {
    id: 1,
    nation: "Kenya",
    text: "For my father's health, that the Lord would grant healing and peace to our home.",
    when: "3m ago",
  },
  {
    id: 2,
    nation: "Brazil",
    text: "Wisdom for a hard decision this week. Pray I would seek Him first.",
    when: "11m ago",
  },
  {
    id: 3,
    nation: "India",
    text: "For our small gathering — that we would love one another well and stay faithful.",
    when: "24m ago",
  },
  {
    id: 4,
    nation: "South Korea",
    text: "Comfort for a friend who is grieving. May she know she is not alone.",
    when: "38m ago",
  },
]

const CONFIRMATIONS = [
  "Someone prayed for you",
  "A believer in Nairobi lifted your name",
  "You were remembered in prayer",
  "Someone is praying with you now",
]

export function UpperRoom() {
  const [playing, setPlaying] = useState(false)
  const [streamSeconds, setStreamSeconds] = useState(0)
  const [activeRoom, setActiveRoom] = useState<string | null>(null)
  const [wall, setWall] = useState<WallRequest[]>(INITIAL_WALL)
  const [draft, setDraft] = useState("")
  const [recording, setRecording] = useState(false)
  const [confirmation, setConfirmation] = useState<string | null>(null)
  const nextId = useRef(100)

  // Ambient stream clock
  useEffect(() => {
    if (!playing) return
    const id = setInterval(() => setStreamSeconds((s) => s + 1), 1000)
    return () => clearInterval(id)
  }, [playing])

  // Quiet, anonymous prayer confirmations
  useEffect(() => {
    let i = 0
    const show = () => {
      setConfirmation(CONFIRMATIONS[i % CONFIRMATIONS.length])
      i += 1
      window.setTimeout(() => setConfirmation(null), 5000)
    }
    const id = setInterval(show, 12000)
    const first = window.setTimeout(show, 3500)
    return () => {
      clearInterval(id)
      clearTimeout(first)
    }
  }, [])

  function submitRequest() {
    const text = draft.trim()
    if (!text) return
    setWall((prev) => [
      { id: nextId.current++, nation: "Your room", text, when: "just now" },
      ...prev,
    ])
    setDraft("")
  }

  const mm = String(Math.floor(streamSeconds / 60)).padStart(2, "0")
  const ss = String(streamSeconds % 60).padStart(2, "0")

  return (
    <div className="relative mx-auto max-w-5xl px-4 py-8">
      {/* Hero: root network */}
      <section className="relative overflow-hidden rounded-3xl border border-[#3a2c14] bg-[#100b06]">
        <div className="absolute inset-x-0 bottom-0 h-40 opacity-90">
          <RootNetwork />
        </div>
        <div className="relative px-6 pt-10 pb-28 text-center">
          <p className="text-xs font-medium uppercase tracking-[0.3em] text-[#e0a441]">
            The Upper Room
          </p>
          <h1 className="mt-3 text-balance text-3xl font-semibold text-[#f4ecd8]">
            Where the Church prays as one
          </h1>
          <p className="mx-auto mt-3 max-w-md text-pretty text-sm leading-relaxed text-[#c9b48a]/80">
            Beneath everything we build, a hidden root system of prayer runs
            quietly through every nation. Come and be still.
          </p>
        </div>
      </section>

      <div className="mt-6 grid gap-6 lg:grid-cols-[minmax(0,1fr)_340px]">
        {/* Left column */}
        <div className="flex flex-col gap-6">
          {/* 24/7 stream player */}
          <section className="rounded-3xl border border-[#3a2c14] bg-[#140d07] p-5">
            <div className="flex items-center gap-4">
              <button
                type="button"
                onClick={() => setPlaying((p) => !p)}
                aria-label={playing ? "Pause prayer stream" : "Play prayer stream"}
                className="flex size-14 shrink-0 items-center justify-center rounded-full bg-[#e0a441] text-[#140d07] transition-colors hover:bg-[#efb659]"
              >
                {playing ? (
                  <Pause className="size-6" aria-hidden="true" />
                ) : (
                  <Play className="ml-0.5 size-6" aria-hidden="true" />
                )}
              </button>
              <div className="min-w-0 flex-1">
                <div className="flex items-center gap-2">
                  <span
                    className={cn(
                      "inline-block size-1.5 rounded-full",
                      playing ? "animate-tree-glow bg-[#e0a441]" : "bg-[#5c4a2a]",
                    )}
                  />
                  <p className="text-xs font-medium uppercase tracking-wider text-[#e0a441]">
                    24 / 7 Prayer Stream
                  </p>
                </div>
                <p className="mt-1 truncate text-sm text-[#f4ecd8]">
                  Continuous intercession · Global room
                </p>
              </div>
              <span className="shrink-0 tabular-nums text-xs text-[#c9b48a]/70">
                {mm}:{ss}
              </span>
            </div>
            {/* gentle waveform */}
            <div className="mt-4 flex h-8 items-end gap-1" aria-hidden="true">
              {Array.from({ length: 40 }).map((_, i) => (
                <span
                  key={i}
                  className={cn(
                    "flex-1 rounded-full bg-[#e0a441]/40",
                    playing && "animate-tree-glow",
                  )}
                  style={{
                    height: `${(20 + Math.abs(Math.sin(i * 0.9)) * 70).toFixed(2)}%`,
                    animationDelay: `${((i % 8) * 0.15).toFixed(2)}s`,
                    opacity: playing ? 1 : 0.25,
                  }}
                />
              ))}
            </div>
          </section>

          {/* Live prayer rooms */}
          <section className="rounded-3xl border border-[#3a2c14] bg-[#140d07] p-5">
            <h2 className="text-sm font-semibold text-[#f4ecd8]">
              Live prayer rooms
            </h2>
            <p className="mt-1 text-xs text-[#c9b48a]/70">
              Join brothers and sisters gathered by nation and language.
            </p>
            <ul className="mt-4 grid gap-2 sm:grid-cols-2">
              {ROOMS.map((room) => {
                const active = activeRoom === room.id
                return (
                  <li key={room.id}>
                    <button
                      type="button"
                      onClick={() =>
                        setActiveRoom((prev) =>
                          prev === room.id ? null : room.id,
                        )
                      }
                      aria-pressed={active}
                      className={cn(
                        "flex w-full items-center justify-between gap-3 rounded-2xl border px-4 py-3 text-left transition-colors",
                        active
                          ? "border-[#e0a441]/60 bg-[#e0a441]/10"
                          : "border-[#3a2c14] bg-[#100b06] hover:border-[#5c4a2a]",
                      )}
                    >
                      <span className="min-w-0">
                        <span className="block truncate text-sm font-medium text-[#f4ecd8]">
                          {room.nation}
                        </span>
                        <span className="block truncate text-xs text-[#c9b48a]/70">
                          {room.language}
                        </span>
                      </span>
                      <span className="flex shrink-0 items-center gap-1 text-xs text-[#c9b48a]">
                        <Users className="size-3.5" aria-hidden="true" />
                        {room.present}
                      </span>
                    </button>
                  </li>
                )
              })}
            </ul>
            {activeRoom && (
              <p className="animate-fruit-pop mt-4 rounded-xl bg-[#e0a441]/10 px-4 py-3 text-xs text-[#e8cf9c]">
                You have quietly joined the{" "}
                {ROOMS.find((r) => r.id === activeRoom)?.nation} room. May you
                sense His nearness here.
              </p>
            )}
          </section>

          {/* Submit prayer request */}
          <section className="rounded-3xl border border-[#3a2c14] bg-[#140d07] p-5">
            <h2 className="text-sm font-semibold text-[#f4ecd8]">
              Share a prayer request
            </h2>
            <p className="mt-1 text-xs text-[#c9b48a]/70">
              Your request is shared gently and anonymously with those praying.
            </p>
            <div className="mt-3 rounded-2xl border border-[#3a2c14] bg-[#100b06] p-3">
              <textarea
                value={draft}
                onChange={(e) => setDraft(e.target.value)}
                rows={3}
                placeholder="Write your request, or hold to speak…"
                className="w-full resize-none bg-transparent text-sm leading-relaxed text-[#f4ecd8] outline-none placeholder:text-[#8a7448]"
              />
              <div className="mt-2 flex items-center justify-between">
                <button
                  type="button"
                  onClick={() => setRecording((r) => !r)}
                  aria-pressed={recording}
                  className={cn(
                    "flex items-center gap-2 rounded-full px-3 py-1.5 text-xs font-medium transition-colors",
                    recording
                      ? "bg-[#e0a441]/20 text-[#efb659]"
                      : "text-[#c9b48a] hover:bg-[#e0a441]/10",
                  )}
                >
                  <Mic
                    className={cn("size-4", recording && "animate-tree-glow")}
                    aria-hidden="true"
                  />
                  {recording ? "Listening…" : "Voice"}
                </button>
                <button
                  type="button"
                  onClick={submitRequest}
                  disabled={draft.trim().length === 0}
                  className="flex items-center gap-2 rounded-full bg-[#e0a441] px-4 py-1.5 text-xs font-medium text-[#140d07] transition-colors hover:bg-[#efb659] disabled:opacity-30"
                >
                  <Send className="size-3.5" aria-hidden="true" />
                  Send up
                </button>
              </div>
            </div>
          </section>
        </div>

        {/* Right column: nation prayer wall */}
        <aside className="rounded-3xl border border-[#3a2c14] bg-[#140d07] p-5">
          <h2 className="text-sm font-semibold text-[#f4ecd8]">
            Nation prayer wall
          </h2>
          <p className="mt-1 text-xs text-[#c9b48a]/70">
            Requests rising from around the world. Pause on one and pray.
          </p>
          <ul className="mt-4 space-y-3">
            {wall.map((req) => (
              <li
                key={req.id}
                className="rounded-2xl border border-[#3a2c14] bg-[#100b06] p-4"
              >
                <div className="flex items-center justify-between">
                  <span className="text-xs font-medium text-[#e0a441]">
                    {req.nation}
                  </span>
                  <span className="text-[11px] text-[#8a7448]">{req.when}</span>
                </div>
                <p className="mt-2 text-pretty text-sm leading-relaxed text-[#e8ddc4]">
                  {req.text}
                </p>
                <PrayButton />
              </li>
            ))}
          </ul>
        </aside>
      </div>

      {/* Anonymous prayer confirmation — quiet, ephemeral */}
      <div
        aria-live="polite"
        className="pointer-events-none fixed inset-x-0 bottom-6 z-40 flex justify-center px-4"
      >
        {confirmation && (
          <div className="animate-fruit-pop rounded-full border border-[#e0a441]/30 bg-[#140d07]/95 px-5 py-2.5 text-sm text-[#e8cf9c] shadow-lg backdrop-blur">
            {confirmation}
          </div>
        )}
      </div>
    </div>
  )
}

function PrayButton() {
  const [prayed, setPrayed] = useState(false)
  return (
    <button
      type="button"
      onClick={() => setPrayed(true)}
      disabled={prayed}
      className={cn(
        "mt-3 w-full rounded-full border px-4 py-2 text-xs font-medium transition-colors",
        prayed
          ? "border-transparent bg-[#e0a441]/10 text-[#8a7448]"
          : "border-[#e0a441]/40 text-[#e0a441] hover:bg-[#e0a441]/10",
      )}
    >
      {prayed ? "You prayed for this. Amen." : "I prayed for this"}
    </button>
  )
}
