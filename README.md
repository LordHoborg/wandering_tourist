# Wandering Tourist

Android portrait 2D game project built with Godot 4 and typed GDScript.

## Current State

The visual storytelling v0.7.2 checkpoint is recorded (2026-09-04): all 15 levels open with an animated humorous briefing featuring an illustrated Milo character; story text uses lighter framing; result screens explain wins and failures with need-specific guidance; item cards use a richer layered presentation; parameter decay follows distinct real-life rhythms; risky item sequences add short-term memory decisions; and the procedural soundtrack uses softer 16-bit synthesis. The full automated suite passes 200/200 including the complete campaign balance gate. The only open gate item is the Phase 4 live human playtest (see `PLAYTEST_PROTOCOL.md`). No Android APK exists yet.

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
