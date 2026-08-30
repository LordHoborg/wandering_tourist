# Wandering Tourist — Master Project Document

## Project Identity

- **Current project status:** Phases 0-2 are complete and approved. Phase 3 (Prototype) is implemented and running: Godot 4.7.1 is installed at `tools/godot`, the playable prototype boots from `scenes/app/app_root.tscn`, three tutorial-progression stages exist, and the automated suite passes 101/101 tests (2026-08-30). Next: gameplay-iteration validation and the Prototype v0.1 checkpoint/APK.

- **Platform:** Android, portrait orientation
- **Engine:** Godot 4.7.1 stable (bundled at `tools/godot`)
- **Language:** Typed GDScript
- **Rendering:** 2D
- **Current phase:** Phase 3 — Prototype (implementation complete, iteration/validation pending)
- **Current version/build:** Desktop prototype build (no Android APK yet)

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
- **Next exact task (project-level):** Complete Phase 3 gameplay validation, record the Prototype v0.1 checkpoint, and begin Android export setup.

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
