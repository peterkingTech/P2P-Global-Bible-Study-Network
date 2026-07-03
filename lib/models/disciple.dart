// ─────────────────────────────────────────────────────────────────────────────
// Disciple model — data comes from Supabase, never hardcoded here.
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

/// Returns the disciple with [id] from [disciples], or null if not found.
Disciple? discipleById(String? id, List<Disciple> disciples) {
  if (id == null) return null;
  try {
    return disciples.firstWhere((d) => d.id == id);
  } catch (_) {
    return null;
  }
}

/// Builds the mentor→disciple edge list from [disciples].
List<MentorEdge> mentorEdges(List<Disciple> disciples) {
  final edges = <MentorEdge>[];
  for (final d in disciples) {
    final mentor = discipleById(d.mentorId, disciples);
    if (mentor != null) {
      edges.add(MentorEdge(from: mentor, to: d, covenant: d.covenant));
    }
  }
  return edges;
}

bool isRecentlyActive(String lastActive) {
  return RegExp(r'now|m ago|h ago').hasMatch(lastActive);
}
