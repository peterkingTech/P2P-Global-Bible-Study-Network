"use client"

import { useEffect, useRef, useState } from "react"
import { Check, Circle, Clock, BookOpen } from "lucide-react"
import { cn } from "@/lib/utils"

const MEMORY_VERSE = {
  ref: "Ecclesiastes 4:9–10",
  text: "Two are better than one, because they have a good reward for their toil. For if they fall, one will lift up his fellow.",
}

const LESSON = {
  title: "Walking Together: The Grace of Companionship",
  subtitle: "Session 4 · The Rhythms of Discipleship",
  paragraphs: [
    "Discipleship was never meant to be a solitary climb. From the very beginning, God declared that it is not good for a person to be alone. The life of faith is lived shoulder to shoulder, in the company of others who are pressing toward the same hope.",
    "When Jesus sent out his followers, he sent them in pairs. There is wisdom in this. A companion sees what we cannot see in ourselves, encourages us when our own strength fails, and holds us to the promises we have made in brighter moments.",
    "To study Scripture together is to invite accountability and joy into the same room. One reads, another listens; one questions, another remembers; and between them the Word takes deeper root than it ever could alone.",
    "Consider how a single ember, pulled from the fire, quickly grows cold — yet gathered with others, it burns steadily through the night. So it is with faith. We were made to keep one another warm.",
    "As you meet today, do not rush. Let the silence between words be unhurried. Pray before you begin, listen more than you speak, and commit together to a single, concrete step of obedience before you part.",
    "The reward, Solomon says, is good. Not because the road is easy, but because you no longer walk it alone. When one of you falls, the other will be there to lift you up. This is the quiet, steady grace of companionship.",
  ],
}

const STEPS = [
  "Both prayed together",
  "Memory verse recited",
  "Content discussed",
  "Assignment committed",
  "Checkpoint completed",
]

export function PeerSession() {
  const [seconds, setSeconds] = useState(0)
  const [checked, setChecked] = useState<boolean[]>(
    () => STEPS.map(() => false),
  )
  const [myProgress, setMyProgress] = useState(0)
  const [peerNote, setPeerNote] = useState<string | null>(
    "Miriam joined the session",
  )
  const [ended, setEnded] = useState(false)
  const [confirming, setConfirming] = useState(false)
  const [reflection, setReflection] = useState("")
  const [saved, setSaved] = useState(false)

  const contentRef = useRef<HTMLDivElement>(null)

  // Session timer
  useEffect(() => {
    if (ended) return
    const id = setInterval(() => setSeconds((s) => s + 1), 1000)
    return () => clearInterval(id)
  }, [ended])

  // Simulated peer presence — gentle, ambient updates only.
  useEffect(() => {
    if (ended) return
    const messages = [
      "Miriam is reading along",
      "Miriam is scrolling",
      "Miriam recited the memory verse",
      "Miriam completed: Both prayed together",
      "Miriam is praying",
      "Miriam highlighted a passage",
    ]
    let i = 0
    const id = setInterval(() => {
      setPeerNote(messages[i % messages.length])
      i += 1
    }, 4200)
    return () => clearInterval(id)
  }, [ended])

  function onScroll() {
    const el = contentRef.current
    if (!el) return
    const max = el.scrollHeight - el.clientHeight
    setMyProgress(max > 0 ? Math.min(1, el.scrollTop / max) : 0)
  }

  function toggleStep(i: number) {
    setChecked((prev) => prev.map((v, idx) => (idx === i ? !v : v)))
  }

  const completedCount = checked.filter(Boolean).length
  const mm = String(Math.floor(seconds / 60)).padStart(2, "0")
  const ss = String(seconds % 60).padStart(2, "0")

  if (ended) {
    return (
      <div className="mx-auto max-w-xl px-4 py-16">
        <div className="rounded-3xl border border-[#e3d9c2] bg-[#fbf7ee] p-8 text-center">
          <div className="mx-auto flex size-14 items-center justify-center rounded-full bg-[#0f6e56]/10">
            <Check className="size-7 text-[#0f6e56]" aria-hidden="true" />
          </div>
          <h1 className="mt-5 text-2xl font-semibold text-[#0f6e56]">
            Session complete
          </h1>
          <p className="mt-2 text-sm leading-relaxed text-[#6b5c3d]">
            You studied together for {mm}:{ss} and completed {completedCount} of{" "}
            {STEPS.length} steps. Take a moment to reflect before you go.
          </p>

          <div className="mt-6 text-left">
            <label
              htmlFor="reflection"
              className="text-sm font-medium text-[#4a3a1e]"
            >
              What is one thing God showed you today?
            </label>
            <textarea
              id="reflection"
              value={reflection}
              onChange={(e) => {
                setReflection(e.target.value)
                setSaved(false)
              }}
              rows={5}
              placeholder="Write a short reflection…"
              className="mt-2 w-full resize-none rounded-2xl border border-[#e3d9c2] bg-white px-4 py-3 text-sm leading-relaxed text-[#4a3a1e] outline-none placeholder:text-[#a8997a] focus:border-[#1d9e75] focus:ring-2 focus:ring-[#1d9e75]/20"
            />
            <button
              type="button"
              onClick={() => setSaved(true)}
              disabled={reflection.trim().length === 0}
              className="mt-3 w-full rounded-full bg-[#0f6e56] px-4 py-2.5 text-sm font-medium text-[#f4efe4] transition-colors hover:bg-[#0c5c48] disabled:opacity-40"
            >
              {saved ? "Reflection saved" : "Save reflection"}
            </button>
            {saved && (
              <p className="animate-fruit-pop mt-3 text-center text-xs text-[#0f6e56]">
                Kept in your journal. Grace and peace.
              </p>
            )}
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-6xl px-4 py-6">
      {/* Top bar: lesson + verse + timer */}
      <header className="rounded-3xl border border-[#e3d9c2] bg-[#fbf7ee] p-5 sm:p-6">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div className="min-w-0">
            <p className="text-xs font-medium uppercase tracking-widest text-[#ba7517]">
              {LESSON.subtitle}
            </p>
            <h1 className="mt-1 text-pretty text-xl font-semibold text-[#0f6e56] sm:text-2xl">
              {LESSON.title}
            </h1>
          </div>
          <div className="flex shrink-0 items-center gap-2 rounded-full bg-[#0f6e56]/10 px-4 py-2">
            <Clock className="size-4 text-[#0f6e56]" aria-hidden="true" />
            <span className="tabular-nums text-sm font-semibold text-[#0f6e56]">
              {mm}:{ss}
            </span>
          </div>
        </div>

        <blockquote className="mt-4 rounded-2xl border-l-2 border-[#ba7517] bg-[#f4efe4] px-4 py-3">
          <p className="text-pretty text-sm italic leading-relaxed text-[#633806]">
            “{MEMORY_VERSE.text}”
          </p>
          <cite className="mt-1 block text-xs font-medium not-italic text-[#ba7517]">
            {MEMORY_VERSE.ref}
          </cite>
        </blockquote>
      </header>

      <div className="mt-5 grid gap-5 lg:grid-cols-[minmax(0,1fr)_340px]">
        {/* Lesson content with scroll tracking */}
        <section className="flex min-h-0 flex-col rounded-3xl border border-[#e3d9c2] bg-[#fbf7ee]">
          <div className="flex items-center justify-between px-5 pt-4">
            <div className="flex items-center gap-2 text-sm font-medium text-[#0f6e56]">
              <BookOpen className="size-4" aria-hidden="true" />
              Lesson reading
            </div>
            <span className="text-xs text-[#8a7b5c]">
              {Math.round(myProgress * 100)}% read
            </span>
          </div>
          {/* progress bar */}
          <div className="mx-5 mt-2 h-1 overflow-hidden rounded-full bg-[#e9e0cb]">
            <div
              className="h-full rounded-full bg-[#1d9e75] transition-[width] duration-200"
              style={{ width: `${myProgress * 100}%` }}
            />
          </div>

          <div
            ref={contentRef}
            onScroll={onScroll}
            className="mt-3 max-h-[46vh] overflow-y-auto px-5 pb-5 lg:max-h-[52vh]"
          >
            {LESSON.paragraphs.map((p, i) => (
              <p
                key={i}
                className="mb-4 text-pretty text-[15px] leading-7 text-[#4a3a1e]"
              >
                {p}
              </p>
            ))}
          </div>
        </section>

        {/* Session panel: peer presence + checklist + end */}
        <aside className="flex flex-col gap-5">
          {/* Peer presence */}
          <div className="rounded-3xl border border-[#e3d9c2] bg-[#fbf7ee] p-5">
            <div className="flex items-center gap-3">
              <div className="relative">
                <div className="flex size-10 items-center justify-center rounded-full bg-[#1d9e75]/15 text-sm font-semibold text-[#0f6e56]">
                  M
                </div>
                <span className="absolute -bottom-0.5 -right-0.5 size-3 rounded-full border-2 border-[#fbf7ee] bg-[#1d9e75]" />
              </div>
              <div className="min-w-0">
                <p className="text-sm font-medium text-[#4a3a1e]">
                  Miriam Osei
                </p>
                <p className="truncate text-xs text-[#8a7b5c]">
                  Your peer guide
                </p>
              </div>
            </div>
            <div
              className="mt-3 flex items-center gap-2 rounded-xl bg-[#f4efe4] px-3 py-2"
              aria-live="polite"
            >
              <span className="flex gap-1" aria-hidden="true">
                <span className="animate-tree-glow size-1.5 rounded-full bg-[#1d9e75]" />
              </span>
              <span className="text-xs text-[#6b5c3d]">{peerNote}</span>
            </div>
          </div>

          {/* Peer guide checklist */}
          <div className="rounded-3xl border border-[#e3d9c2] bg-[#fbf7ee] p-5">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold text-[#0f6e56]">
                Peer guide checklist
              </h2>
              <span className="text-xs text-[#8a7b5c]">
                {completedCount}/{STEPS.length}
              </span>
            </div>
            <ul className="mt-3 space-y-1.5">
              {STEPS.map((step, i) => {
                const isChecked = checked[i]
                return (
                  <li key={step}>
                    <button
                      type="button"
                      onClick={() => toggleStep(i)}
                      aria-pressed={isChecked}
                      className={cn(
                        "flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left text-sm transition-colors",
                        isChecked
                          ? "bg-[#0f6e56]/10 text-[#0f6e56]"
                          : "text-[#4a3a1e] hover:bg-[#f4efe4]",
                      )}
                    >
                      <span
                        className={cn(
                          "flex size-5 shrink-0 items-center justify-center rounded-md border transition-colors",
                          isChecked
                            ? "border-[#0f6e56] bg-[#0f6e56] text-[#f4efe4]"
                            : "border-[#cdbf9f] text-transparent",
                        )}
                      >
                        {isChecked ? (
                          <Check className="size-3.5" aria-hidden="true" />
                        ) : (
                          <Circle className="size-0" aria-hidden="true" />
                        )}
                      </span>
                      <span>{step}</span>
                    </button>
                  </li>
                )
              })}
            </ul>
          </div>

          {/* End session */}
          <button
            type="button"
            onClick={() => setConfirming(true)}
            className="rounded-full border border-[#d8b78a] bg-transparent px-4 py-2.5 text-sm font-medium text-[#ba7517] transition-colors hover:bg-[#ba7517]/10"
          >
            End session
          </button>
        </aside>
      </div>

      {/* End confirmation */}
      {confirming && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-[#1a1206]/40 p-4">
          <div
            role="dialog"
            aria-modal="true"
            aria-labelledby="end-title"
            className="animate-fruit-pop w-full max-w-sm rounded-3xl border border-[#e3d9c2] bg-[#fbf7ee] p-6 text-center"
          >
            <h2
              id="end-title"
              className="text-lg font-semibold text-[#0f6e56]"
            >
              End this session?
            </h2>
            <p className="mt-2 text-sm leading-relaxed text-[#6b5c3d]">
              You&apos;ve completed {completedCount} of {STEPS.length} steps.
              You&apos;ll be able to write a short reflection afterward.
            </p>
            <div className="mt-5 flex gap-3">
              <button
                type="button"
                onClick={() => setConfirming(false)}
                className="flex-1 rounded-full bg-[#e9e0cb] px-4 py-2.5 text-sm font-medium text-[#6b5c3d] transition-colors hover:bg-[#ddd2b8]"
              >
                Keep studying
              </button>
              <button
                type="button"
                onClick={() => {
                  setConfirming(false)
                  setEnded(true)
                }}
                className="flex-1 rounded-full bg-[#0f6e56] px-4 py-2.5 text-sm font-medium text-[#f4efe4] transition-colors hover:bg-[#0c5c48]"
              >
                End session
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
