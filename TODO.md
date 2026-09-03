# TODO

## Phase 0 — Concept Analysis

- [x] Obtain and review the original Wandering Tourist concept PDF.
- [x] Identify gameplay loop, systems, scope, controls, conditions, parameters, balancing, risks, roadmap, and architecture options.
- [x] Record ambiguities with alternatives and recommendations.
- [x] Approve first-playable parameters, time-limited survival direction, and fixed lane controls.
- [x] Add and verify the original PDF at `docs/source/Wandering Tourist - Game Document.pdf`.
- [x] Approve hybrid item-effect model `DEC-006`.
- [x] Formally defer exact timer, score, boundary, balancing, lane-to-parameter, item-effect, and feedback values to Phase 1/prototype iteration.
- [x] Close the Phase 0 completion checkpoint.

## Phase 1 — Executable Game Design Document

- [x] Receive authorization and complete executable Prototype v0.1 GDD.
- [x] Record configurable rules, balancing, item matrix, and acceptance criteria.
- [x] Receive explicit approval to begin Phase 2.
- [x] Add recovery fairness, contextual trade-off scoring, and core-fun validation to the Phase 1 GDD.

## Phase 2 - Technical Architecture

- [x] Define modular Godot architecture, scene tree, data resources, signals, ownership, and test strategy.
- [x] Record autoload, state-machine, event, and input-abstraction decisions.
- [x] Receive explicit approval to begin Phase 3 prototype implementation.
- [x] Install or provide current stable Godot 4, then create and test Prototype v0.1.

## Phase 3 - Prototype

- [x] Implement core services, coordinator, spawn/fairness systems, and UI presenters.
- [x] Implement 3-stage tutorial progression with objectives and destinations.
- [x] Update the coordinator integration test for the stage model; full suite 101/101 green (2026-08-30).
- [x] Record the Prototype v0.1 checkpoint (2026-08-30, see master document).

## Phase 4 - Gameplay Iteration

- [x] Build the automated balance-validation harness (`tests/integration/test_balance_validation.gd`).
- [x] Verify decay pressure, winnability, inert invalid taps, 7/3 bag, lane fairness, best-score persistence, and determinism (TR-012; suite 114/114).
- [ ] Run the five-person live playtest for AC-05..AC-08, AC-10, AC-11 per `PLAYTEST_PROTOCOL.md` and record results as TR-013 in `TEST_REPORT.md`.
- [ ] Apply any balance changes the playtest demands, with documented hypothesis and re-test.

## Phase 5 - Vertical Slice

- [x] Add title screen with best score and settings UI (sound, SFX volume, reduced motion).
- [x] Persist `AppSettings` to `user://app_settings.cfg` with clamped setters.
- [x] Add procedural `AudioDirector`: runtime-synthesized cues for all presentation events, mute/volume gating, settings injection.
- [x] Add warning-band pulse with reduced-motion fallback and 5-second reminder cues (`WarningMonitor`).
- [x] Add stage progress dots, result-overlay best score, journey-complete variant, and pause restart confirmation (R twice).
- [x] Add unit suites for settings, audio, and warning timing; full suite 140/140 green plus clean headless boot (TR-014, 2026-08-31).
- [x] Record the Vertical Slice v0.5 checkpoint (2026-08-31, see master document).
- [x] Fix campaign score carry-over across stages with retry rollback (v0.5.1, TR-015).
- [x] Overhaul procedural visuals: shared animated tropical backdrop, lane/action-line polish, item cards, HUD meters, overlay stars (v0.5.1, TR-015); suite 143/143.
- [x] Close GDD touch gaps: visible pause button, tap-to-act overlays with dismissal grace, campaign restart (v0.5.2, TR-016).
- [x] Add game feel and ambient audio: electric-bolt cuts, item sway, lerped meters, spirit pips, looping ambience (v0.5.2, TR-016); suite 148/148.
- [x] Re-read the complete source PDF and add decision-aware item guidance, weakest-need HUD priority, three procedural destination themes, and spirit milestone audio (v0.5.3, TR-017); suite 152/152.
- [x] Add front-item cut-window telegraphing, lane pulse feedback, and dedicated timing cue without changing the approved cut rules (v0.5.4, TR-018); suite 153/153.
- [x] Re-read the complete PDF and expand the playable slice to a 15-level campaign: staged Social/Hygiene parameters, full recovery/hazard/trade-off item catalog, five destination families, dynamic HUD, and active-parameter fairness validation (v0.6.0, 2026-09-03); suite 179/179.
- [x] Add 15 animated story/tutorial briefings, realistic differentiated decay rhythms with Hunger at 3× baseline, risky recent-item combo rules, and softened 16-bit procedural audio (v0.7.0, 2026-09-03); suite 184/184.

## Future Phases

- [ ] Phase 6: Android Build (export templates, presets, first APK).
- [ ] Phase 7: Content Expansion.
