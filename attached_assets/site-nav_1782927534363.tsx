"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { Sprout, Globe2, BookOpenText, Flame } from "lucide-react"
import { cn } from "@/lib/utils"

const LINKS = [
  { href: "/", label: "Journey", icon: Sprout },
  { href: "/forest", label: "Global Forest", icon: Globe2 },
  { href: "/session", label: "Peer Session", icon: BookOpenText },
  { href: "/upper-room", label: "Upper Room", icon: Flame },
]

export function SiteNav() {
  const pathname = usePathname()

  return (
    <header className="sticky top-0 z-50 border-b border-[#1d5544]/60 bg-[#0b3a2e]/95 backdrop-blur supports-[backdrop-filter]:bg-[#0b3a2e]/80">
      <nav className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-3">
        <Link href="/" className="flex items-center gap-2">
          <span className="flex size-7 items-center justify-center rounded-full bg-[#1d9e75]/20 ring-1 ring-[#1d9e75]/40">
            <Sprout className="size-4 text-[#9fe1cb]" aria-hidden="true" />
          </span>
          <span className="text-sm font-semibold tracking-tight text-[#f4efe4]">
            Vine &amp; Branches
          </span>
        </Link>

        <ul className="flex items-center gap-1">
          {LINKS.map(({ href, label, icon: Icon }) => {
            const active =
              href === "/" ? pathname === "/" : pathname.startsWith(href)
            return (
              <li key={href}>
                <Link
                  href={href}
                  aria-current={active ? "page" : undefined}
                  className={cn(
                    "flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-medium transition-colors",
                    active
                      ? "bg-[#9fe1cb] text-[#0b3a2e]"
                      : "text-[#9fe1cb]/80 hover:bg-[#1d5544]/60 hover:text-[#f4efe4]",
                  )}
                >
                  <Icon className="size-4" aria-hidden="true" />
                  <span className="hidden sm:inline">{label}</span>
                </Link>
              </li>
            )
          })}
        </ul>
      </nav>
    </header>
  )
}
