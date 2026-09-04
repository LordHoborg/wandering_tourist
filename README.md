# Wandering Tourist

Android portrait 2D game project built with Godot 4 and typed GDScript.

## Current State

The mobile stability v0.8.1 checkpoint is recorded (2026-09-04): Android export is locked to portrait, menu and gameplay use separate soft ambience loops, audio stream switching is lifecycle-safe, and animated backdrops are capped at 30 FPS for lower mobile load. The full automated suite passes 202/202. A signed arm64 debug Android APK is available at `exports/wandering_tourist_v0.8.1_mobile_test.apk` after export.

Run the game: `tools\godot\Godot_v4.7.1-stable_win64.exe --path .`

Run a test suite headless: `tools\godot\Godot_v4.7.1-stable_win64_console.exe --headless --path . --script tests/integration/test_progression.gd`

## Documentation

`MASTER_PROJECT_DOCUMENT.md` is the single source of truth. Read it first, then consult the specialized project documents listed there.

`PHASE_0_CONCEPT_ANALYSIS.md` records the evidence-based Phase 0 analysis of the original concept PDF.

## Folder Structure

| Path | Purpose |
| --- | --- |
| `docs/source/` | Immutable source materials retained for project continuity. |
| `autoload/` | Global singletons (`AppSettings`). |
| `scenes/app/` | Application root scene and lifecycle boundary. |
| `scenes/gameplay/` | Gameplay root scene and presenter wiring. |
| `scripts/data/` | Data/resource definitions (parameters, items, levels, stages). |
| `scripts/game/` | Pure game logic services and the gameplay coordinator. |
| `scripts/state/` | Runtime state objects (parameter state, item instances). |
| `scripts/ui/` | HUD, playfield, item view, feedback, and overlay presenters. |
| `tests/unit/`, `tests/integration/` | Headless SceneTree test scripts. |
| `tools/godot/` | Bundled Godot 4.7.1 editor and console binaries. |

The original vision is retained at `docs/source/Wandering Tourist - Game Document.pdf`.

## Getting Started

1. Launch the prototype with the bundled Godot binary (command above).
2. On the title screen, adjust sound/volume/reduced-motion if desired, then start the trip.
3. Play: tap/click the left or right lane area to cut the front item; Space pauses/resumes, R twice while paused restarts, R once on a result screen starts a fresh trip, N advances after completion.

Export Android APK: `tools\godot\Godot_v4.7.1-stable_win64_console.exe --headless --path . --export-debug "Android" "exports\wandering_tourist_v0.8.1_mobile_test.apk"`

The APK is a debug sideload build. Android/Google Play Protect may show an App Scan notice for APKs installed outside Google Play; this is a distribution warning, not a game crash report.
