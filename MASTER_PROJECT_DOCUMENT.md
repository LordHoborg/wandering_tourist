# Wandering Tourist — Master Project Document

## Project Identity

- **Platform:** Android, portrait orientation
- **Engine:** Godot 4 latest stable/LTS
- **Language:** Typed GDScript
- **Rendering:** 2D
- **Current phase:** Phase 0 — Concept Analysis
- **Current version/build:** Not started / no build

## Source Material Status

The original vision is the 8-page `docs/source/Wandering Tourist - Game Document.pdf` (dated 2023). It was reviewed for Phase 0, but the PDF is not yet stored at that repository-relative location. Add the source file there before Phase 1 so the project remains self-contained. The PDF confirms a four-section portrait layout with two confirmed active falling-item areas, bottom electric-line controls, and parameter management. The Phase 0 analysis records interpretations and unresolved details separately from source evidence.

## Confirmed First-Playable Constraints

One island and one level; Hunger, Rest, and Fun parameters; touch and mouse support; simple UI and placeholder visuals; basic animations; pause, restart, timer, score, and best score. Excluded: ads, cosmetics, shop, online/social/account systems, analytics, monetization, and multiple islands.

## Governance

- Do not begin production code before Phase 0 approval.
- Document every file, scene, script, resource, autoload, and signal before or with its creation.
- Store gameplay values in documented configuration resources or central data files; do not hardcode balancing values.
- Each milestone requires a documented checkpoint and, when available, a playable Android APK.

## Current Checkpoint

- **Completed analysis:** Source PDF extraction and visual review; confirmed layout and controls; gameplay-loop, system, risk, prototype-scope, control, parameter, balancing, roadmap, and architecture analysis; documentation baseline and consistency checks.
- **Approved decisions:** Hunger, Rest, and Fun for the first playable; two fixed electric-line lane controls resolving the front-most eligible item; time-limited survival for the prototype.
- **Proposed decisions:** Treat failure after a parameter leaves a configurable safe range; compare simple, contextual, and hybrid item-effect models; use a hybrid item model as the recommended prototype test.
- **Unresolved questions:** Exact timer duration, score formula, safe-boundary semantics, balancing values, lane-to-parameter mapping, item-effect matrix, and whether the PDF's four sections map to only two active lanes plus utility/HUD regions.
- **Work remaining before approval:** Record the official source PDF at `docs/source/Wandering Tourist - Game Document.pdf`; approve or amend the proposed item model and remaining design decisions; confirm all open questions are intentionally deferred to Phase 1/prototype iteration.
- **Known bugs:** None; no executable project exists.
- **Project health:** Documentation is current; Phase 0 awaits design decisions and approval.
- **Next exact task:** Decide the prototype item-effect model and confirm the Phase 1 deferrals, then formally approve or amend the Phase 0 checkpoint.

## Document Index

| Document | Purpose |
| --- | --- |
| `README.md` | Project orientation and current state |
| `GAME_DESIGN_DOCUMENT.md` | Executable design specification after Phase 0 approval |
| `TECHNICAL_ARCHITECTURE.md` | Technical design after Phase 0 approval |
| `PHASE_0_CONCEPT_ANALYSIS.md` | Evidence-based Phase 0 analysis and decision backlog |
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
