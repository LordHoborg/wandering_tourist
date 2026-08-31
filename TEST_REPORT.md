# Test Report

## TR-014 - Phase 5 Vertical Slice Polish Verification

- **Date:** 2026-08-31
- **Godot:** 4.7.1.stable.official.a13da4feb (headless, `tools/godot`)
- **Scope:** New Phase 5 presentation layer: `AppSettings` persistence (`user://app_settings.cfg`), procedural `AudioDirector` (runtime-synthesized WAV cues, settings-injected, mute/volume gating), `WarningMonitor` band-entry/reminder timing, title screen, HUD warning pulse and stage dots, overlay best-score/journey-complete polish, and pause restart confirmation.
- **Method:** Three new unit suites — `test_app_settings.gd` (defaults, clamping, persistence round-trip, missing file), `test_audio_director.gd` (cue coverage for every coordinator presentation event, WAV validity, synthesis determinism/silence, mute/zero-volume inertness, unknown-cue no-op, volume-to-decibel mapping), `test_warning_monitor.gd` (band entry, 5s reminder, exit reset, re-entry, upper band, simultaneous bands) — plus full-suite regression and a 90-frame headless boot of `scenes/app/app_root.tscn`.
- **Results:** New suites 26 passed / 0 failed. Full suite: 140 passed, 0 failed across 11 suites. Boot smoke: exit 0, no script errors.
- **Regression check:** TR-012 balance harness still 13/13; no gameplay rule or balance value changed.
- **Known limitation:** Title-screen layout, audio mix, and reduced-motion behavior are verified headless only; on-device look/feel is covered by the Phase 4 human playtest (`PLAYTEST_PROTOCOL.md`) and Phase 6 device testing.

## TR-012 - Phase 4 Automated Balance Validation Gate

- **Date:** 2026-08-30
- **Godot:** 4.7.1.stable.official.a13da4feb (headless, `tools/godot`)
- **Scope:** New `tests/integration/test_balance_validation.gd` harness plus a full-suite regression run.
- **Method:** Deterministic simulated players verify the mechanical acceptance criteria: every stage fails under total neglect (decay pressure is real), a state-aware bot clears the full three-stage campaign, invalid taps are inert (AC-04), stage 3 keeps the approved 7-simple/3-trade bag with no runaway lane streaks (AC-03), best score submits and persists across sessions (AC-09), and identical bot campaigns produce identical outcomes.
- **Results:** Balance harness 13 passed / 0 failed. Full suite including the new harness: 114 passed, 0 failed.
- **Regression check:** All prior suites re-ran green; no balance value required tuning.
- **Known limitation:** Human acceptance criteria (AC-05 through AC-08, AC-10, AC-11) require live testers and remain open; they are the only outstanding Phase 4 evidence.

## TR-011 - Phase 3 Full Suite Re-Verification

- **Date:** 2026-08-30
- **Godot:** 4.7.1.stable.official.a13da4feb (headless, `tools/godot`)
- **Scope:** All unit and integration suites plus a headless boot smoke check of `scenes/app/app_root.tscn`.
- **Change under test:** `tests/integration/test_gameplay_coordinator.gd` was updated for the stage-progression model: it now clears the persisted best-score file up front, neutralizes passive decay to isolate the timer-completion path, uses `level.completion_bonus` instead of a hardcoded 500, and drives deterministic runs with repeated 0.1-second ticks instead of one 120-second tick.
- **Results:** `test_item_resolver` 7/0, `test_lane_input_adapter` 4/0, `test_parameter_service` 9/0, `test_services` 14/0, `test_spawn_systems` 47/0, `test_gameplay_coordinator` 11/0, `test_progression` 9/0.
- **Total verified:** 101 passed, 0 failed.
- **Regression check:** Headless project boot exits cleanly with no script errors.
- **Known issues:** None open; see `KNOWN_BUGS.md` LIM-003 for the missing Android export.

## TR-010 - Phase 3 Service Gate

- **Date:** 2026-08-10
- **Godot:** 4.7.1.stable.official.a13da4feb
- **External verified results:** Foundation suite 9 passed/0 failed; service check-only exit 0; service runtime 14 passed/0 failed, exit 0.
- **Total verified:** 23 passed, 0 failed.

## TR-001 — Phase 0 Documentation Baseline

- **Date:** 2026-08-09
- **Scope:** Required documentation files
- **Manual test:** Confirmed all required initial documentation files exist and record the current phase and missing concept source.
- **Expected result:** Project handoff material is present without undocumented design assumptions.
- **Actual result:** Pass.
- **Regression check:** Not applicable; no executable implementation exists.
- **Known issues:** This baseline test preceded receipt of the concept PDF; see TR-002 for the current review state.

## TR-002 — Concept PDF Review

- **Date:** 2026-08-09
- **Scope:** `Wandering Tourist - Game Document.pdf` (8 pages)
- **Manual test:** Extracted all eight pages and visually inspected the cover, gameplay mock-up, and legacy monetization pages.
- **Expected result:** Capture the source mechanics and distinguish current-scope constraints from legacy PDF features.
- **Actual result:** Pass. Verified two main falling-item lanes, electric-line taps, parameter thresholds, thematic-island progression, and legacy monetization/cosmetics.
- **Regression check:** Confirmed first-playable scope still excludes ads, coins, cosmetics, shop, online, analytics, and multiple islands.
- **Known issues:** Open design decisions A-001 through A-005 remain pending approval.

## TR-003 — Phase 0 Review-Follow-Up Documentation Check

- **Date:** 2026-08-09
- **Scope:** Phase 0 checkpoint, analysis, decision log, GDD, technical architecture, TODO, and changelog.
- **Manual test:** Confirmed approved decisions are marked as approved, time-limited survival retains configurable values, the layout is not described as four active lanes, and negative-item behavior is marked as unconfirmed.
- **Expected result:** Source evidence, approved direction, proposals, and open questions are distinguishable.
- **Actual result:** Pass.
- **Regression check:** Confirmed no Phase 1 implementation authorization was introduced.
- **Known issues:** Superseded by TR-004 after the source copy was verified and `DEC-006` was approved.

## TR-004 — Phase 0 Completion Check

- **Date:** 2026-08-09
- **Scope:** Canonical source retention, Phase 0 decision status, and completion checkpoint.
- **Manual test:** Copied the source PDF to `docs/source/Wandering Tourist - Game Document.pdf` and compared SHA-256 hashes with the supplied file; reviewed the checkpoint, decision log, backlog, roadmap, and GDD for approved/deferred status.
- **Expected result:** Source is repository-local, DEC-006 is approved with configurable 70/30 hybrid direction, and no Phase 0 blockers remain.
- **Actual result:** Pass. The source hashes match; Phase 0 is closed; Phase 1 remains unstarted.
- **Regression check:** Confirmed the deferred timer, scoring, boundary, balancing, lane mapping, item matrix, and feedback details did not become fixed implementation requirements.
- **Known issues:** None. No executable project exists yet.
