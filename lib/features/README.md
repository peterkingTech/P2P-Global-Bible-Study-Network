# Vine & Branches — Flutter Feature Widgets

Converted from React/Next.js (Tailwind CSS) source.
All colors are centralized in `lib/config/theme.dart`.
All data models live in `lib/models/`.

## Widget Inventory

| React source | Flutter target |
|---|---|
| `site-nav.tsx` | `lib/features/navigation/widgets/site_nav.dart` |
| `living-tree.tsx` | `lib/features/living_tree/widgets/living_tree_widget.dart` |
| `stage-journey.tsx` | `lib/features/stage_journey/widgets/stage_journey_widget.dart` |
| `root-network.tsx` | `lib/features/root_network/widgets/root_network_widget.dart` |
| `upper-room.tsx` | `lib/features/upper_room/widgets/upper_room_widget.dart` |
| `peer-session.tsx` | `lib/features/peer_session/widgets/peer_session_widget.dart` |
| `world-map.tsx` | `lib/features/world_map/widgets/world_map_widget.dart` |
| `tree-data.ts` | `lib/models/growth_stage.dart` |
| `forest-data.ts` | `lib/models/disciple.dart` |

## Usage Examples

### Shell (navigation frame)
```dart
VineBranchesShell(
  pages: [
    JourneyPage(),
    GlobalForestPage(),
    PeerSessionWidget(),
    UpperRoomWidget(),
  ],
)
```

### Living Tree — full variant driven by real metrics
```dart
LivingTreeWidget(
  metrics: GrowthMetrics(
    studiesCompleted: 14,
    peersConnected: 8,
    disciples: 3,
    prayers: 47,
    streakDays: 21,
    nationsReached: 4,
  ),
  onZoneSelect: (zone) => print('Tapped $zone'),
)
```

### Living Tree — mini variant (for lists / leaderboards)
```dart
LivingTreeWidget(level: 3, mini: true)
```

### Stage Journey
```dart
StageJourneyWidget(metrics: myMetrics)
```

### World Map (interactive, seasonal)
```dart
WorldMapWidget(
  season: 'autumn',
  filters: MapFilters(stages: {2, 3}, activity: 'praying'),
  onHover: (disciple) { /* show tooltip elsewhere */ },
)
```

### Upper Room
```dart
UpperRoomWidget()
```

### Peer Session
```dart
PeerSessionWidget()
```

### Root Network (decorative, atmospheric)
```dart
SizedBox(height: 160, child: RootNetworkWidget())
```

## Required pubspec.yaml dependencies
```yaml
dependencies:
  flutter_screenutil: ^5.9.0

# Image assets — add tree stage images:
flutter:
  assets:
    - assets/tree/
```

## Animation summary

| Component | Animation | Flutter API |
|---|---|---|
| All trees | Breathing (scale pulse) | `AnimationController` + `ScaleTransition` |
| Root Network | Glow pulse + node flicker | `AnimationController` + `CustomPainter` |
| Tap zones | Pulsing ring on active | `AnimationController` + `ScaleTransition` + `FadeTransition` |
| Stream player | Animated waveform bars | `AnimationController` + `AnimatedBuilder` |
| Stage dots | Smooth color transitions | `AnimatedContainer` |
| Progress bars | Width animation | `LinearProgressIndicator` value |
| Confirmation toast | Fade in/out | `AnimatedOpacity` |
| Peer status dot | Opacity pulse | `AnimationController` + `FadeTransition` |
| World map nodes | Glow breathe | `AnimationController` + `CustomPainter` |
| World map zoom | Pan + scale | State-driven `CustomPainter` repaint |
