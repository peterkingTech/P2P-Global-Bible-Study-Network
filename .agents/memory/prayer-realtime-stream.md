---
name: Prayer realtime stream
description: How realtimePrayerWallProvider correctly emits updated lists when Supabase Postgres changes fire
---

## Rule
`realtimePrayerWallProvider` (a `StreamProvider`) must use a `StreamController` bridge to re-fetch and `yield` a fresh list on each Postgres change event. Simply calling `ref.invalidate(prayerWallProvider)` inside the callback does NOT cause the stream to re-yield.

**Why:** `StreamProvider` runs as an `async*` generator. `ref.invalidate` rebuilds the underlying `FutureProvider` but the generator has already yielded past its `await for` loop — it won't see the change unless something explicitly yields again inside the loop.

**How to apply:**
```dart
final controller = _PrayerStreamController();
channel.onPostgresChanges(..., callback: (_) => controller.trigger());
await for (final _ in controller.stream) {
  final updated = await fetchFromSupabase();
  yield updated;
}
```
`_PrayerStreamController` is a thin wrapper around `StreamController<void>.broadcast()`.
