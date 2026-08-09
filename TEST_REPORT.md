# Test Report

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
