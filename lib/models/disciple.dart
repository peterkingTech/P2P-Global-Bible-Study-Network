// ─────────────────────────────────────────────────────────────────────────────
// Disciple model + data — mirrors forest-data.ts
// ─────────────────────────────────────────────────────────────────────────────

class Disciple {
  final String id;
  final String name;
  final String city;
  final String country;
  /// [longitude, latitude]
  final List<double> coordinates;
  final String stage;
  final int level;
  final String lastActive;
  final bool praying;
  final String? mentorId;
  final bool covenant;

  const Disciple({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.coordinates,
    required this.stage,
    required this.level,
    required this.lastActive,
    required this.praying,
    this.mentorId,
    this.covenant = false,
  });
}

class MentorEdge {
  final Disciple from;
  final Disciple to;
  final bool covenant;
  const MentorEdge({
    required this.from,
    required this.to,
    required this.covenant,
  });
}

const String kViewerId = 'you';

const List<Disciple> kDisciples = [
  Disciple(
    id: 'you',
    name: 'You',
    city: 'Austin',
    country: 'United States',
    coordinates: [-97.74, 30.27],
    stage: 'fruitful-tree',
    level: 3,
    lastActive: 'now',
    praying: true,
  ),
  Disciple(
    id: 'grace',
    name: 'Grace Adeyemi',
    city: 'Lagos',
    country: 'Nigeria',
    coordinates: [3.38, 6.52],
    stage: 'forest-of-nations',
    level: 5,
    lastActive: '2m ago',
    praying: true,
    mentorId: 'you',
    covenant: true,
  ),
  Disciple(
    id: 'samuel',
    name: 'Samuel Okoro',
    city: 'Nairobi',
    country: 'Kenya',
    coordinates: [36.82, -1.29],
    stage: 'fruitful-tree',
    level: 3,
    lastActive: '18m ago',
    praying: true,
    mentorId: 'grace',
    covenant: true,
  ),
  Disciple(
    id: 'hannah',
    name: 'Hannah Lee',
    city: 'Seoul',
    country: 'South Korea',
    coordinates: [126.98, 37.57],
    stage: 'young-tree',
    level: 2,
    lastActive: '1h ago',
    praying: false,
    mentorId: 'you',
  ),
  Disciple(
    id: 'david',
    name: 'David Mensah',
    city: 'Accra',
    country: 'Ghana',
    coordinates: [-0.19, 5.6],
    stage: 'sprout',
    level: 1,
    lastActive: '3h ago',
    praying: true,
    mentorId: 'grace',
  ),
  Disciple(
    id: 'ruth',
    name: 'Ruth Nakamura',
    city: 'Tokyo',
    country: 'Japan',
    coordinates: [139.69, 35.68],
    stage: 'dormant-seed',
    level: 0,
    lastActive: 'yesterday',
    praying: false,
    mentorId: 'hannah',
  ),
  Disciple(
    id: 'maria',
    name: 'Maria Silva',
    city: 'São Paulo',
    country: 'Brazil',
    coordinates: [-46.63, -23.55],
    stage: 'forest-builder',
    level: 4,
    lastActive: '34m ago',
    praying: true,
    mentorId: 'you',
    covenant: true,
  ),
  Disciple(
    id: 'diego',
    name: 'Diego Ramírez',
    city: 'Bogotá',
    country: 'Colombia',
    coordinates: [-74.07, 4.71],
    stage: 'young-tree',
    level: 2,
    lastActive: '5h ago',
    praying: false,
    mentorId: 'maria',
  ),
  Disciple(
    id: 'amara',
    name: 'Amara Okafor',
    city: 'London',
    country: 'United Kingdom',
    coordinates: [-0.12, 51.5],
    stage: 'fruitful-tree',
    level: 3,
    lastActive: '12m ago',
    praying: true,
    mentorId: 'grace',
  ),
  Disciple(
    id: 'priya',
    name: 'Priya Nair',
    city: 'Mumbai',
    country: 'India',
    coordinates: [72.87, 19.07],
    stage: 'forest-builder',
    level: 4,
    lastActive: '8m ago',
    praying: true,
    mentorId: 'amara',
    covenant: true,
  ),
  Disciple(
    id: 'chen',
    name: 'Chen Wei',
    city: 'Singapore',
    country: 'Singapore',
    coordinates: [103.82, 1.35],
    stage: 'young-tree',
    level: 2,
    lastActive: '2h ago',
    praying: false,
    mentorId: 'priya',
  ),
  Disciple(
    id: 'yusuf',
    name: 'Yusuf Demir',
    city: 'Istanbul',
    country: 'Türkiye',
    coordinates: [28.98, 41.01],
    stage: 'sprout',
    level: 1,
    lastActive: '6h ago',
    praying: true,
    mentorId: 'amara',
  ),
  Disciple(
    id: 'lena',
    name: 'Lena Novak',
    city: 'Berlin',
    country: 'Germany',
    coordinates: [13.4, 52.52],
    stage: 'young-tree',
    level: 2,
    lastActive: '45m ago',
    praying: false,
    mentorId: 'you',
  ),
  Disciple(
    id: 'sofia',
    name: 'Sofia Rossi',
    city: 'Rome',
    country: 'Italy',
    coordinates: [12.5, 41.9],
    stage: 'sprout',
    level: 1,
    lastActive: '1d ago',
    praying: false,
    mentorId: 'lena',
  ),
  Disciple(
    id: 'james',
    name: 'James Carter',
    city: 'Sydney',
    country: 'Australia',
    coordinates: [151.21, -33.87],
    stage: 'fruitful-tree',
    level: 3,
    lastActive: '22m ago',
    praying: true,
    mentorId: 'you',
  ),
  Disciple(
    id: 'abebe',
    name: 'Abebe Tadesse',
    city: 'Addis Ababa',
    country: 'Ethiopia',
    coordinates: [38.75, 9.03],
    stage: 'sprout',
    level: 1,
    lastActive: '4h ago',
    praying: true,
    mentorId: 'samuel',
  ),
];

Disciple? discipleById(String? id) {
  if (id == null) return null;
  try {
    return kDisciples.firstWhere((d) => d.id == id);
  } catch (_) {
    return null;
  }
}

List<MentorEdge> mentorEdges() {
  final edges = <MentorEdge>[];
  for (final d in kDisciples) {
    final mentor = discipleById(d.mentorId);
    if (mentor != null) {
      edges.add(MentorEdge(from: mentor, to: d, covenant: d.covenant));
    }
  }
  return edges;
}

bool isRecentlyActive(String lastActive) {
  return RegExp(r'now|m ago|h ago').hasMatch(lastActive);
}
