# Wandering Tourist — Master Project Document

## Project Identity

- **Current project status:** Phases 0-3 are complete and the live human/device playtest remains open. The v0.8.3 mobile-stability checkpoint (2026-09-04) keeps portrait orientation, replaces runtime background synthesis with imported menu/game WAV loops, controls playback retries, uses a lightweight Android backdrop, and provides a signed debug APK; suite 205/205 green.

- **Platform:** Android, portrait orientation
- **Engine:** Godot 4.7.1 stable (bundled at `tools/godot`)
- **Language:** Typed GDScript
- **Rendering:** 2D
- **Current phase:** Phase 4 human playtest evidence is the only open gate item; narrative systems checkpoint recorded
- **Current version/build:** Mobile Stability v0.8.3 (2026-09-04: portrait Android export, imported calm menu music and gameplay ambience, controlled audio retries, lightweight Android backdrop, signed debug APK at `exports/wandering_tourist_v0.8.3_mobile_stable.apk`)

## Source Material Status

The original vision is the 8-page `docs/source/Wandering Tourist - Game Document.pdf` (dated 2023). The source copy was added and SHA-256-verified against the supplied PDF on 2026-08-09. The PDF confirms a four-section portrait layout with two confirmed active falling-item areas, bottom electric-line controls, and parameter management. The Phase 0 analysis records interpretations and unresolved details separately from source evidence.

## Confirmed First-Playable Constraints

One island and one level; Hunger, Rest, and Fun parameters; touch and mouse support; simple UI and placeholder visuals; basic animations; pause, restart, timer, score, and best score. Excluded: ads, cosmetics, shop, online/social/account systems, analytics, monetization, and multiple islands.

## Governance

- Do not begin production code before Phase 0 approval.
- Document every file, scene, script, resource, autoload, and signal before or with its creation.
- Store gameplay values in documented configuration resources or central data files; do not hardcode balancing values.
- Each milestone requires a documented checkpoint and, when available, a playable Android APK.

## Phase 0 Completion Checkpoint

- **Status:** COMPLETE — Phase 0 is formally closed. Phase 1 has not started.
- **Phase 0 completion:** 100%.
- **Current version/build:** Not started / no build.
- **Completed analysis:** Source PDF extraction and visual review; confirmed layout and controls; gameplay-loop, systems, risks, prototype scope, controls, parameters, balancing, roadmap, and architecture analysis; documentation baseline and consistency checks.
- **Approved decisions:** Hunger, Rest, and Fun; two fixed electric-line lane controls resolving the front-most eligible item; time-limited survival; hybrid item-effect model with approximately 70% simple single-parameter items and 30% visually distinct contextual multi-parameter trade-off items; intentionally small, readable prototype item pool; configurable ratios.
- **Intentionally deferred:** Exact timer duration, score formula, safe-boundary semantics, balancing values, lane-to-parameter mapping, exact item-effect matrix, and visual/audio feedback details. These are Phase 1/prototype-iteration decisions.
- **Incomplete features:** No Godot project, production code, scene, asset pipeline, automated test, Android export configuration, or APK exists; all are outside completed Phase 0 scope.
- **Open questions:** None block Phase 0. Deferred choices are tracked and must be resolved through Phase 1/prototype iteration.
- **Known bugs:** See `KNOWN_BUGS.md`.
- **Project health:** Healthy; source material is repository-local and the Phase 0 handoff is complete.
- **Next exact task (project-level):** Run the five-person live playtest for AC-05 through AC-08, AC-10, and AC-11 per `PLAYTEST_PROTOCOL.md`, record results as TR-013 in `TEST_REPORT.md`, then proceed to Phase 6 (Android export).

## Vertical Slice v0.5 Checkpoint (2026-08-31)

- **Polish added over Prototype v0.1:** Title screen with best score and a settings UI (sound on/off, stepped SFX volume, reduced motion) backed by persisted `AppSettings`; a procedural `AudioDirector` synthesizing all cue WAVs at runtime (no binary audio assets) for every presentation event, warning reminders, and UI start; warning-band meter pulses with reduced-motion static fallback; five-second warning reminder cues; stage progress dots; journey-complete result variant with best score on the result overlay; pause restart now requires R-twice confirmation per the GDD while result-screen restart stays immediate.
- **Architecture notes:** `AudioDirector` takes its settings node by injection (composition root wires the `AppSettings` autoload) so it compiles and runs in headless test rigs; warning timing logic lives in the pure `WarningMonitor` class, cue emission in the HUD view layer; gameplay rules and balance values are unchanged.
- **Verification:** 140 automated checks across 11 suites, all passing (new: `test_app_settings.gd` 5, `test_audio_director.gd` 10, `test_warning_monitor.gd` 11), plus a clean 90-frame headless boot of `app_root.tscn`; the TR-012 balance harness still passes 13/13 untouched.
- **Out of checkpoint scope:** Android export/APK (Phase 6), final art and music, and human acceptance criteria AC-05 through AC-08, AC-10, AC-11 (playtest protocol ready in `PLAYTEST_PROTOCOL.md`).

## Vertical Slice v0.5.3 Checkpoint (2026-09-02)

- **Polish added over v0.5.2:** The coordinator now publishes a weakest-need priority and a decision label for every active item (`COLLECT`, `LET PASS`, `GOOD CHOICE`, `SAVE IT`, or `TOO RISKY`) so the intended brain of the game is visible in the playfield. The HUD identifies the current destination and priority parameter. Stages use distinct procedural destination palettes: sunlit tropical cove, sunset neon harbor, and ancient ruins. Spirit milestones have a dedicated audio cue and visual callout.
- **Source alignment:** The full 8-page source PDF was re-read and visually inspected on 2026-09-02. The two active falling-item lanes, bottom electric-line controls, parameter management, themed-island progression, and legacy monetization exclusions remain the governing first-playable direction.
- **Verification:** Full automated suite: 152 passed, 0 failed across 11 suites; stage progression now includes theme and decision-guidance assertions. Headless boot is clean; windowed visual verification remains part of the manual playtest/device gate.

## Vertical Slice v0.5.4 Checkpoint (2026-09-03)

- **Polish added over v0.5.3:** The coordinator announces the exact moment the front item in each lane enters the 0.60-second cut window. The playfield responds with a lane pulse and the feedback layer names the available action, while a dedicated procedural cue provides optional audio reinforcement. Rear items do not trigger false telegraphs.
- **Verification:** Full automated suite: 153 passed, 0 failed across 11 suites; progression covers deterministic cut-window announcement state and audio covers the new presentation event. Headless boot is clean.

## PDF-Aligned Content Expansion v0.6.0 Checkpoint (2026-09-03)

- **Gameplay expansion:** The campaign now contains 15 configured levels. Hunger, Rest, and Fun are active in levels 1-5; Social is introduced at level 6; Hygiene is introduced at level 11. Each level increases time pressure and rotates through tropical, neon-city, countryside, ancient-ruins, and crystal-isles destination presentations.
- **Items:** The catalog now includes recovery and hazard items for all five needs plus contextual trade-offs for social and hygiene decisions. Spawn bags remain the approved 7-simple/3-trade shape once trade-offs unlock, and fairness validation now evaluates every active parameter.
- **Presentation:** The HUD renders only the parameters active in the current level, shows 15-level progress, labels the current destination, and supports the expanded item vocabulary with distinct icons and effect chips.
- **Verification:** Full automated suite: 179 passed, 0 failed across 11 suites; progression validates level unlocks and item catalog coverage, balance validation confirms neglect pressure and bot winnability across the full campaign, and headless boot exits cleanly.

## Island Atmosphere v0.8.0 Checkpoint (2026-09-04)

- **Visual identity:** Each five-level chapter has its own atmosphere. Sunlit Cove combines turquoise water, beach details, palms, hut, birds, and sea foam; Neon Harbor uses a sunset-night gradient, stars, layered skyline, neon signage, tower beacon, street geometry, and water reflections; Serene Country uses warm sky rays, layered green hills, crop rows, trees, barn, fence, and a moving windmill.
- **Rendering:** Added finer sky/sea bands, theme-specific sun glow, cloud shading, reflections, and subtle foreground color grading without covering the action lanes.
- **Android build:** Enabled ETC2/ASTC texture import, added the Android preset, and exported a signed arm64 debug APK. Device installation and touch acceptance remain part of the user's phone playtest.
- **Verification:** Full automated suite remains 200 passed, 0 failed across 11 suites; headless boot exits 0; Android export and APK verification complete.

## Mobile Stability v0.8.1 Checkpoint (2026-09-04)

- **Orientation:** Corrected the Android preset key to `display/window/handheld/orientation=1`; exported manifest reports `screenOrientation=1`, and Android runtime requests portrait as a second safeguard.
- **Audio:** Added a separate low-volume sustained-chord menu loop and safe stop/replace/play transitions between menu, briefing, and gameplay ambience.
- **Performance:** Title and playfield procedural redraws are capped at 30 FPS while reduced-motion mode remains static.
- **Verification:** Full automated suite is 202/202 across 11 suites; 30-second headless stability run exits 0; APK signature verifies with v2/v3; package version is 0.8.1 and minimum SDK is 24.
- **Distribution note:** This is a debug sideload APK, so Android/Google Play Protect can display an App Scan notice because it was installed outside Google Play.

## Narrative Systems v0.7.0 Checkpoint (2026-09-03)

- **Story flow:** Every level begins on a full-screen animated briefing. Fifteen humorous chapters follow Milo, an enthusiastic island tourist with poor self-care habits, while progressively teaching controls, parameters, contextual items, warnings, Travel Spirit, and the Social/Hygiene island transitions at levels 6 and 11.
- **Need rhythms:** Hunger now decays at three times the prior stage baseline. Rest, Fun, Social, and Hygiene use progressively slower multipliers (2.15, 1.55, 0.72, 0.48) to model realistic urgency rather than synchronized meter loss.
- **Sequence decisions:** From level 3 onward, recent collected items matter. Double Coffee, Too Much Food, No Sleep Tour, and Crowd Overload apply combined penalties inside documented time windows; cards publish `WAIT` and preview the effective deltas before the cut.
- **Audio:** Runtime audio moved from harsh normalized 8-bit synthesis to low-register 16-bit PCM with softer envelopes, quieter ambience, heavily smoothed surf, and restrained harmonics.
- **Verification:** Full automated suite: 200 passed, 0 failed across 11 suites; windowed captures verify the Milo briefing, lighter story framing, item-card presentation, and result layouts; all 15 story entries pass safe-area checks; balance validation clears all 15 levels under state-aware play; headless project boot is clean.

## Prototype v0.1 Checkpoint (2026-08-30)

- **Playable content:** Three sequential tropical stages — Basic Needs (65s), Watch Out (85s), Tough Choices (100s) — with staged hazard unlocks, per-item familiarity (NEW/LEARNING/KNOWN), objectives, and destination data.
- **Systems:** Deterministic spawn bags with recovery-fairness repair, lane fairness, contextual trade-off scoring with momentum, pause/resume/restart/advance, best-score persistence, reduced-motion and mute settings.
- **Verification:** 114 automated checks across 8 suites, all passing, including the Phase 4 balance-validation harness (`tests/integration/test_balance_validation.gd`): every stage is losable under neglect and winnable by a state-aware bot, invalid taps are inert, the 7/3 bag and lane-streak rules hold, and bot campaigns are deterministic.
- **Out of checkpoint scope:** Android export/APK, audio assets, final art, and human acceptance criteria AC-05 through AC-08, AC-10, AC-11.

## Document Index

| Document | Purpose |
| --- | --- |
| `README.md` | Project orientation and current state |
| `GAME_DESIGN_DOCUMENT.md` | Executable design specification after Phase 0 approval |
| `TECHNICAL_ARCHITECTURE.md` | Technical design after Phase 0 approval |
| `PHASE_0_CONCEPT_ANALYSIS.md` | Evidence-based Phase 0 analysis and decision backlog |
| `docs/source/README.md` | Source-document retention and verification record |
| `ROADMAP.md` | Phase and milestone plan |
| `TODO.md` | Actionable work list |
| `DECISION_LOG.md` | Durable decisions and unresolved items |
| `CHANGELOG.md` | Versioned project changes |
| `KNOWN_BUGS.md` | Verified defects and limitations |
| `TEST_REPORT.md` | Test evidence |
| `BUILD_NOTES.md` | Build/export metadata and process |

## Change History

| Date | Change |
| --- | --- |
| 2026-08-09 | Created Phase 0 documentation baseline; recorded missing concept PDF. |
| 2026-08-09 | Reviewed the original concept PDF and updated the Phase 0 analysis, decision log, scope, roadmap, and test evidence. |
| 2026-08-09 | Recorded approved first-playable parameters, prototype controls, and time-limited survival direction; added contextual item-model investigation. |
| 2026-08-09 | Added and verified the canonical source PDF; approved the hybrid item-effect direction; closed Phase 0. |
| 2026-08-30 | Synced status with reality: Godot 4.7.1 installed, prototype implemented with 3-stage progression, coordinator integration test updated for the stage model, full suite 101 passed / 0 failed. |
| 2026-08-30 | Recorded the Prototype v0.1 checkpoint; added the Phase 4 automated balance-validation harness (13 checks); suite now 114 passed / 0 failed; entered Phase 4 with only human playtest evidence outstanding. |
