---
name: Peer session widget patterns
description: How helper StatelessWidgets in peer_session_widget.dart mutate parent ConsumerState without triggering protected-member warnings
---

## Rule
When a `StatelessWidget` helper (e.g. `_SessionComplete`, `_SidePanel`) needs to call `setState` on its parent `ConsumerState`, do NOT call `s.setState(...)` directly — it is a protected member and triggers analyzer warnings.

**Why:** Flutter's `setState` is marked `@protected`; calling it from an external class produces `invalid_use_of_protected_member` warnings and breaks `flutter analyze` gates.

**How to apply:** Add public callback methods to the parent state class:
```dart
void setSaved(bool value) => setState(() => _saved = value);
void toggleChecked(int index) => setState(() => _checked[index] = !_checked[index]);
void setConfirming(bool value) => setState(() => _confirming = value);
```
Helper widgets call `s.setSaved(true)` etc. instead of `s.setState(...)`.
