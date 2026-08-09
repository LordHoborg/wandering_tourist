# Wandering Tourist — Master Project Document

## Project Identity

- **Platform:** Android, portrait orientation
- **Engine:** Godot 4 latest stable/LTS
- **Language:** Typed GDScript
- **Rendering:** 2D
- **Current phase:** Phase 0 — Concept Analysis
- **Current version/build:** Not started / no build

## Source Material Status

The original vision was reviewed from `G:\Desktop\Desktop\Wandering Tourist - Game Document.pdf` (8 pages, dated 2023). It defines a four-lane falling-item game where the player taps electric lines to cut items while maintaining parameters. The Phase 0 analysis records conflicts and unresolved details; it does not silently convert them into implementation decisions.

## Confirmed First-Playable Constraints

One island and one level; Hunger, Rest, and Fun parameters; touch and mouse support; simple UI and placeholder visuals; basic animations; pause, restart, timer, score, and best score. Excluded: ads, cosmetics, shop, online/social/account systems, analytics, monetization, and multiple islands.

## Governance

- Do not begin production code before Phase 0 approval.
- Document every file, scene, script, resource, autoload, and signal before or with its creation.
- Store gameplay values in documented configuration resources or central data files; do not hardcode balancing values.
- Each milestone requires a documented checkpoint and, when available, a playable Android APK.

## Current Checkpoint

- **Completed:** Documentation baseline; source-material availability check.
- **Incomplete:** All concept, loop, systems, controls, conditions, balancing, roadmap, and architecture analysis.
- **Open questions:** Initial parameter mapping, lane-to-parameter mapping, positive/negative item behavior, timer/score rules, level completion rule, and final control affordance.
- **Known bugs:** None; no executable project exists.
- **Project health:** Documentation is current; Phase 0 awaits design decisions and approval.
- **Next exact task:** Review the Phase 0 recommendations in `PHASE_0_CONCEPT_ANALYSIS.md` and approve or amend the open decisions.

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
