# Wandering Tourist

Android portrait 2D game project built with Godot 4 and typed GDScript.

## Current State

The coin-economy v0.9.0 checkpoint is recorded (2026-09-04): the PDF-aligned wallet, yellow/green/blue reward bubbles, optional double-coin challenges, post-level payout, and cosmetic closet are implemented. Android remains portrait with separate imported WAV loops and a signed arm64 debug export. The full automated suite passes 222/222.

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

Export Android APK: `tools\godot\Godot_v4.7.1-stable_win64_console.exe --headless --path . --export-debug "Android" "exports\wandering_tourist_v0.9.0_coins.apk"`

The APK is a debug sideload build. Android/Google Play Protect may show an App Scan notice for APKs installed outside Google Play; this is a distribution warning, not a game crash report.
