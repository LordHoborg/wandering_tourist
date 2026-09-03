# Changelog

## v0.8.0 - 2026-09-04

- Rebuilt the procedural backdrop as three visually distinct island chapters: Sunlit Cove uses bright tropical water, palms, a beach hut, birds, and foam; Neon Harbor uses a dusk gradient, stars, skyline depth, neon signs, tower lights, and reflected city glow; Serene Country uses warm daylight, layered hills, crops, trees, a barn, fence, and animated windmill.
- Added richer atmospheric layers, sun glows, water reflections, cloud shadows, and foreground color grading while preserving readable gameplay lanes.
- Added Android ETC2/ASTC texture-import configuration and a reproducible Android export preset.
- Built and verified the signed debug APK: `exports/wandering_tourist_v0.8.0_debug.apk`.

## v0.7.2 - 2026-09-04

- Added a custom illustrated Milo character cutout to every story briefing.
- Replaced the heavy per-line story boxes with lightweight guide accents and a compact travel-tip card.
- Upgraded item cards with deeper shadows, layered surfaces, brighter category lighting, framed icon plates, and cleaner decision badges.

## v0.7.1 - 2026-09-03

- Rewrote stage-completion and failure messaging with story-specific guidance, clearer retry/continue actions, and a more polished results card.
- Rebuilt pre-stage briefing cards so long text stays clipped and wrapped inside safe bounds throughout its entrance animation.
- Added automated safe-area checks for all 15 briefing chapters.

All notable project changes are recorded here.

- v0.7.0: narrative and rhythm pass — animated humorous briefing before all 15 levels, level 6/11 island-transition stories, differentiated faster decay (Hunger 3× baseline with progressively slower Rest/Fun/Social/Hygiene), four risky item-sequence rules with `WAIT` previews, and softer low-register 16-bit procedural music/SFX; suite 184/184.
- v0.6.0: PDF-aligned content expansion — 15-level campaign with Social at level 6 and Hygiene at level 11, recovery/hazard items for all five needs, six contextual trade-offs, five destination families including countryside and crystal isles, dynamic five-need HUD, and active-parameter fairness validation; suite 179/179.
- v0.5.4: timing and readability pass — the front item announces entry into the cut window, lanes pulse before action, a dedicated procedural cue reinforces timing, and rear items remain quiet until they become actionable; suite 153/153 (TR-018).
- v0.5.3: source-aligned gameplay/presentation pass — active items publish decision guidance and reasons, HUD highlights the weakest need and destination, stages gain tropical/sunset-city/ancient-ruins procedural themes, and spirit milestones receive a dedicated cue and callout; suite 152/152 (TR-017).
- v0.5.2: GDD compliance and game feel — visible touch pause button, tap-to-act overlays with dismissal grace, campaign restart after the final stage, electric-bolt cut effect, item sway, lerped HUD meters, spirit pips, looping procedural ambience, pause/resume cues; suite 148/148 (TR-016).
- v0.5.1: fixed campaign score not carrying across stages (carries forward on advance; retry rolls back to the stage-entry total); full procedural visual overhaul — shared animated tropical backdrop (sky, sun, clouds, waves, island, beach, palms), glassy lane panels with glowing action lines and cut-flash rings, item cards with category bands and effect chips, rounded HUD meters with safe-zone ticks, drawn star ratings on the result overlay, and a screenshot capture dev tool; suite 143/143 (TR-015).
- Phase 5 Vertical Slice v0.5: title screen with settings UI, persisted `AppSettings`, procedural `AudioDirector` cues for all events, warning pulse with reminder cues, stage dots, result-overlay best score and journey-complete variant, and pause restart confirmation; suite 140/140 (TR-014).
- Added `PLAYTEST_PROTOCOL.md`: session script, recording sheets, pass/fail tally, and TR-013 report template for the remaining Phase 4 human criteria (AC-05..AC-08, AC-10, AC-11).
- Recorded the Prototype v0.1 checkpoint and entered Phase 4 (Gameplay Iteration).
- Added the automated balance-validation harness (13 checks: neglect pressure, campaign winnability, inert taps, 7/3 bag, lane fairness, best-score persistence, determinism); suite now 114 passed, 0 failed.
- Rewrote the coordinator integration test for the stage-progression model (removed the legacy fixed-120-second assumptions); full suite now 101 passed, 0 failed.
- Synced master document, roadmap, TODO, known bugs, test report, and build notes with the implemented Phase 3 prototype state.
- Recorded verified Phase 3 foundation/service gate: 23 tests passed, 0 failed.
- Added item transaction and deterministic spawn/fairness foundations.

## Unreleased

### Added

- Phase 0 documentation baseline.
- Evidence-based Phase 0 concept analysis from the original PDF.

### Changed

- First-playable scope explicitly defers the original document's ads, coins, cosmetics, extra parameters, and extra islands.
- Clarified the source layout as four sections with two confirmed active falling-item areas.
- Recorded approved parameter, time-limited survival, and fixed-control directions; added the hybrid item-model investigation.
- Added the canonical concept PDF and formally closed Phase 0.
- Added the executable Prototype v0.1 GDD, Phase 1 decisions, configurable balance defaults, and acceptance criteria.
- Added item-family recovery fairness, context-sensitive trade-off scoring, and core-fun validation criteria.
- Added Phase 2 Godot architecture, folder/scene plan, data contracts, signal map, and test strategy.
- Corrected presenter signal ownership and added AppRoot lifecycle translation boundary.
