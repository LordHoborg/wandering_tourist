# Test Report

## TR-020 - v0.7.0 Narrative, Need Rhythms, and Sequence Decisions

- **Date:** 2026-09-03
- **Godot:** 4.7.1.stable.official.a13da4feb
- **Scope:** Address player feedback about harsh music, slow synchronized parameter loss, missing story/tutorial flow, and insufficient short-term decision complexity.
- **Changes:** Rebuilt procedural ambience/cues as quieter 16-bit PCM; introduced per-parameter decay multipliers with Hunger at 3× baseline; added 15 animated humorous pre-level briefings; added four timed item-sequence penalties and `WAIT` decision previews.
- **Method:** Audio format/loop/determinism checks, progression assertions for story coverage/level 6 and 11 transitions/decay ordering/tripled Hunger/combo expiry, full campaign balance simulation using effective combo deltas, clean headless boot, and windowed screenshot capture.
- **Results:** 184 passed, 0 failed across 11 suites. Progression 25/25; balance 37/37; audio 14/14. Briefing capture is readable at the project portrait viewport.
- **Known limitation:** Audio pleasantness and story pacing still require the user's ongoing human playtest; Android device verification remains open.

## TR-019 - v0.6.0 PDF-Aligned Content Expansion

- **Date:** 2026-09-03
- **Godot:** 4.7.1.stable.official.a13da4feb (headless, `tools/godot`)
- **Scope:** Complete the source PDF's item and progression direction without adding the explicitly deferred monetization systems: staged parameter unlocks, expanded item vocabulary, multi-level destination progression, and responsive presentation.
- **Changes:** Added 15 configured levels; activated Social at level 6 and Hygiene at level 11; added recovery and hazard items for all five needs plus Street Festival, Spa Day, and Group Tour trade-offs; extended spawn-bag fairness to the active parameter set; added countryside and crystal-isles procedural destinations; and updated the HUD/item cards for five needs and 15-level progress.
- **Method:** Full headless regression across all 11 suites, campaign balance validation across every level, progression assertions for unlock timing/catalog coverage, and headless project boot.
- **Results:** 179 passed, 0 failed across 11 suites. Balance validation passes neglect pressure, full-campaign bot winnability, lane fairness, persistence, inert taps, and determinism. Headless boot exits cleanly.
- **Known limitation:** Final Android device verification, final art/music, and the five-person human acceptance playtest remain open.

## TR-018 - v0.5.4 Cut-Window Telegraphing

- **Date:** 2026-09-03
- **Godot:** 4.7.1.stable.official.a13da4feb (headless, `tools/godot`)
- **Scope:** Improve timing readability while preserving the approved 0.60-second cut window and front-most eligible-item rule.
- **Changes:** `ItemInstance` tracks whether its cut window was announced; the coordinator emits `cut_window_open` only for the front item; the playfield renders a brief lane pulse; the feedback layer names the current action; `AudioDirector` adds a timing cue. Headless audio playback is guarded when nodes are outside the scene tree.
- **Method:** Progression assertion for deterministic front-item telegraph state, audio cue coverage, full-suite regression, and clean headless boot.
- **Results:** 153 passed, 0 failed across 11 suites. Progression suite: 18/18.
- **Known limitation:** Human timing feel remains part of the ongoing manual playtest and future Android device verification.

## TR-017 - v0.5.3 Decision Guidance and Destination Themes

- **Date:** 2026-09-02
- **Godot:** 4.7.1.stable.official.a13da4feb (headless, `tools/godot`)
- **Scope:** Source-aligned gameplay and presentation pass after a complete re-read and visual inspection of the 8-page concept PDF.
- **Changes:** Active items now publish decision labels from current parameter state; the HUD shows the weakest need and destination identity; stages use distinct procedural tropical, sunset-city, and ancient-ruins palettes; spirit milestones add a dedicated procedural cue and visual callout.
- **Method:** Added progression assertions for stage themes and decision labels; full-suite regression; clean headless boot. Windowed presentation remains covered by the manual playtest/device gate.
- **Results:** 152 passed, 0 failed across 11 suites. New progression suite: 17/17.
- **Known limitation:** The PDF's additional parameters, multiple islands, monetization, and social systems remain intentionally out of first-playable scope. Human acceptance criteria and Android device verification remain open.

## TR-016 - v0.5.2 Touch Controls, Game Feel, and Ambient Audio

- **Date:** 2026-09-02
- **Godot:** 4.7.1.stable.official.a13da4feb (headless, `tools/godot`)
- **Scope:** GDD compliance gap — pause was keyboard-only although the GDD requires an always-visible touch/mouse pause, and result/pause overlays were not touch-operable. Also game-feel and audio upgrades.
- **Changes:** Visible touch pause button during runs; overlay tap-to-resume/restart/advance with a 0.4s dismissal grace so the tap producing a result cannot skip its screen; `restart_campaign()` for a fresh journey after the final stage (resets stage, score baseline, familiarity); electric-bolt zap on cuts per the PDF's electric-line concept (straight flash under reduced motion); falling-item sway/rotation; lerped HUD meters; spirit momentum pips; looping procedural ambience (ocean surf + pentatonic plucks) with settings-driven volume; pause/resume cues.
- **Method:** New assertions — ambience loop/length/determinism/player checks in `test_audio_director.gd`, campaign-reset check in `test_progression.gd`; full-suite regression; headless boot smoke; windowed screenshot capture of title and gameplay.
- **Results:** Audio suite 14/14, progression suite 13/13. Full suite: 148 passed, 0 failed across 11 suites. Boot smoke: exit 0, no script errors.
- **Regression check:** TR-012 balance harness still 13/13; no gameplay rule, timing, or balance value changed.
- **Known limitation:** Zap/sway/ambience feel are verified by screenshots and headless checks; human feel assessment rides on the ongoing manual playtests and Phase 6 device testing.

## TR-015 - v0.5.1 Campaign Score Fix + Visual Overhaul

- **Date:** 2026-09-01
- **Godot:** 4.7.1.stable.official.a13da4feb (headless, `tools/godot`)
- **Scope:** Player-reported defect: the score reset to zero on stage advance instead of carrying through the campaign. Also a full procedural visual overhaul (shared `TropicalBackdrop`, playfield lanes, item cards, HUD meters, overlay stars, title screen) plus a screenshot capture dev tool.
- **Hypothesis (score fix):** `advance_stage()` discarded the accumulated `ScoreService`, so the campaign total never grew across stages. Fix: carry the total into the next stage via `stage_entry_score`; retrying a stage rolls back to that baseline so failed attempts cannot be farmed.
- **Method:** New progression assertions (carry into stage 2, growth during stage 2, rollback on retry) in `tests/integration/test_progression.gd`; full-suite regression; headless boot smoke; windowed screenshot capture of title and gameplay reviewed for overlap/readability defects (hint/HUD overlap and title subtitle/island overlap found and fixed).
- **Results:** Progression suite 12/12 (3 new checks). Full suite: 143 passed, 0 failed across 11 suites. Boot smoke: exit 0, no script errors.
- **Regression check:** TR-012 balance harness still 13/13; item values, timings, and decay unchanged — only score persistence semantics across stages changed.
- **Known limitation:** Visual quality is verified by captured screenshots at 360x640; small/large device verification remains with the Phase 4 human playtest and Phase 6 device testing.

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
