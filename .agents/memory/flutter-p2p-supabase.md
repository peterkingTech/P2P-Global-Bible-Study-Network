---
name: Flutter P2P Supabase setup
description: How Supabase credentials are injected into the Flutter web app at compile time
---

## Rule
Supabase URL and anon key must be passed via `--dart-define` flags at compile/run time. They are consumed in `main.dart` via `String.fromEnvironment('SUPABASE_URL')`.

**Why:** Flutter web compiles Dart to JS; environment variables from the OS are not accessible at runtime. `--dart-define` bakes values into the compiled output.

**How to apply:** The Flutter Web workflow command must always include:
```
--dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```
The Replit secrets `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set and confirmed by the user. If Supabase calls silently return empty results, check the workflow command first.
