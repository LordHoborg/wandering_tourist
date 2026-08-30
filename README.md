# Wandering Tourist

Android portrait 2D game project built with Godot 4 and typed GDScript.

## Current State

The project is in Phase 4 (Gameplay Iteration). The Prototype v0.1 checkpoint is recorded: a playable desktop prototype with three tutorial-progression stages, deterministic spawning, scoring with momentum, best-score persistence, and pause/restart. The full automated suite passes 114/114 including the balance-validation gate (2026-08-30). Remaining Phase 4 work is live human playtesting. No Android APK exists yet.

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
2. Play: tap/click the left or right lane area to cut the front item; Space pauses/resumes, R restarts, N advances after completion.
3. See `TODO.md` for the remaining Phase 3 validation work.
