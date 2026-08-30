# Changelog

All notable project changes are recorded here.

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
