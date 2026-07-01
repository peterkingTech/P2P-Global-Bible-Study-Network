import type { StageId } from "@/components/living-tree/tree-data"

export type Season = "spring" | "summer" | "autumn" | "winter"

export interface Disciple {
  id: string
  name: string
  city: string
  country: string
  /** [longitude, latitude] */
  coordinates: [number, number]
  stage: StageId
  /** growth level 0-5, mirrors the Living Tree */
  level: number
  lastActive: string
  praying: boolean
  /** the disciple who mentors this person, if any */
  mentorId?: string
  /** true when this bond is a sealed "Paul–Timothy" covenant */
  covenant?: boolean
}

/**
 * "You" — the viewer. Relationship filtering is anchored to this id.
 */
export const VIEWER_ID = "you"

export const DISCIPLES: Disciple[] = [
  {
    id: "you",
    name: "You",
    city: "Austin",
    country: "United States",
    coordinates: [-97.74, 30.27],
    stage: "fruitful-tree",
    level: 3,
    lastActive: "now",
    praying: true,
  },
  {
    id: "grace",
    name: "Grace Adeyemi",
    city: "Lagos",
    country: "Nigeria",
    coordinates: [3.38, 6.52],
    stage: "forest-of-nations",
    level: 5,
    lastActive: "2m ago",
    praying: true,
    mentorId: "you",
    covenant: true,
  },
  {
    id: "samuel",
    name: "Samuel Okoro",
    city: "Nairobi",
    country: "Kenya",
    coordinates: [36.82, -1.29],
    stage: "fruitful-tree",
    level: 3,
    lastActive: "18m ago",
    praying: true,
    mentorId: "grace",
    covenant: true,
  },
  {
    id: "hannah",
    name: "Hannah Lee",
    city: "Seoul",
    country: "South Korea",
    coordinates: [126.98, 37.57],
    stage: "young-tree",
    level: 2,
    lastActive: "1h ago",
    praying: false,
    mentorId: "you",
  },
  {
    id: "david",
    name: "David Mensah",
    city: "Accra",
    country: "Ghana",
    coordinates: [-0.19, 5.6],
    stage: "sprout",
    level: 1,
    lastActive: "3h ago",
    praying: true,
    mentorId: "grace",
  },
  {
    id: "ruth",
    name: "Ruth Nakamura",
    city: "Tokyo",
    country: "Japan",
    coordinates: [139.69, 35.68],
    stage: "dormant-seed",
    level: 0,
    lastActive: "yesterday",
    praying: false,
    mentorId: "hannah",
  },
  {
    id: "maria",
    name: "Maria Silva",
    city: "São Paulo",
    country: "Brazil",
    coordinates: [-46.63, -23.55],
    stage: "forest-builder",
    level: 4,
    lastActive: "34m ago",
    praying: true,
    mentorId: "you",
    covenant: true,
  },
  {
    id: "diego",
    name: "Diego Ramírez",
    city: "Bogotá",
    country: "Colombia",
    coordinates: [-74.07, 4.71],
    stage: "young-tree",
    level: 2,
    lastActive: "5h ago",
    praying: false,
    mentorId: "maria",
  },
  {
    id: "amara",
    name: "Amara Okafor",
    city: "London",
    country: "United Kingdom",
    coordinates: [-0.12, 51.5],
    stage: "fruitful-tree",
    level: 3,
    lastActive: "12m ago",
    praying: true,
    mentorId: "grace",
  },
  {
    id: "priya",
    name: "Priya Nair",
    city: "Mumbai",
    country: "India",
    coordinates: [72.87, 19.07],
    stage: "forest-builder",
    level: 4,
    lastActive: "8m ago",
    praying: true,
    mentorId: "amara",
    covenant: true,
  },
  {
    id: "chen",
    name: "Chen Wei",
    city: "Singapore",
    country: "Singapore",
    coordinates: [103.82, 1.35],
    stage: "young-tree",
    level: 2,
    lastActive: "2h ago",
    praying: false,
    mentorId: "priya",
  },
  {
    id: "yusuf",
    name: "Yusuf Demir",
    city: "Istanbul",
    country: "Türkiye",
    coordinates: [28.98, 41.01],
    stage: "sprout",
    level: 1,
    lastActive: "6h ago",
    praying: true,
    mentorId: "amara",
  },
  {
    id: "lena",
    name: "Lena Novak",
    city: "Berlin",
    country: "Germany",
    coordinates: [13.4, 52.52],
    stage: "young-tree",
    level: 2,
    lastActive: "45m ago",
    praying: false,
    mentorId: "you",
  },
  {
    id: "sofia",
    name: "Sofia Rossi",
    city: "Rome",
    country: "Italy",
    coordinates: [12.5, 41.9],
    stage: "sprout",
    level: 1,
    lastActive: "1d ago",
    praying: false,
    mentorId: "lena",
  },
  {
    id: "james",
    name: "James Carter",
    city: "Sydney",
    country: "Australia",
    coordinates: [151.21, -33.87],
    stage: "fruitful-tree",
    level: 3,
    lastActive: "22m ago",
    praying: true,
    mentorId: "you",
  },
  {
    id: "abebe",
    name: "Abebe Tadesse",
    city: "Addis Ababa",
    country: "Ethiopia",
    coordinates: [38.75, 9.03],
    stage: "sprout",
    level: 1,
    lastActive: "4h ago",
    praying: true,
    mentorId: "samuel",
  },
]

export interface Stat {
  label: string
  value: string
}

export const GLOBAL_STATS: Stat[] = [
  { label: "fruit borne globally", value: "24,817" },
  { label: "cities reached", value: "156" },
  { label: "praying right now", value: "847" },
  { label: "covenant bonds", value: "5,204" },
]

export const SEASON_THEME: Record<
  Season,
  {
    label: string
    /** map ocean / base background */
    ocean: string
    /** country land fill */
    land: string
    /** country border */
    border: string
    /** dominant node glow */
    node: string
    /** accent / covenant */
    accent: string
    caption: string
  }
> = {
  spring: {
    label: "Spring — Blossom",
    ocean: "#07130f",
    land: "#12281f",
    border: "#1d4d3b",
    node: "#f7b8d2",
    accent: "#f7c948",
    caption: "New believers blossoming across the earth.",
  },
  summer: {
    label: "Summer — Verdant",
    ocean: "#06110d",
    land: "#0f2a20",
    border: "#1d5c44",
    node: "#1d9e75",
    accent: "#f7c948",
    caption: "The Church in full, verdant strength.",
  },
  autumn: {
    label: "Autumn — Harvest",
    ocean: "#120c06",
    land: "#2a1c0f",
    border: "#5c3d1d",
    node: "#e0821a",
    accent: "#f7c948",
    caption: "The fields are white for harvest.",
  },
  winter: {
    label: "Winter — Waiting",
    ocean: "#080c11",
    land: "#161f2a",
    border: "#33445c",
    node: "#9fe1cb",
    accent: "#cbd8e1",
    caption: "Quiet, hidden growth beneath the frost.",
  },
}

export function discipleById(id?: string): Disciple | undefined {
  if (!id) return undefined
  return DISCIPLES.find((d) => d.id === id)
}

/** All mentor→mentee edges, with covenant flag carried from the mentee. */
export function mentorEdges(): {
  from: Disciple
  to: Disciple
  covenant: boolean
}[] {
  const edges: { from: Disciple; to: Disciple; covenant: boolean }[] = []
  for (const d of DISCIPLES) {
    const mentor = discipleById(d.mentorId)
    if (mentor) edges.push({ from: mentor, to: d, covenant: Boolean(d.covenant) })
  }
  return edges
}
