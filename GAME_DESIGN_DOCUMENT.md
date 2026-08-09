# Game Design Document

## Status

Phase 0 reference draft. It becomes the executable design specification in Phase 1 after approval of the recorded open decisions.

## Confirmed Constraints

- Android portrait 2D game.
- The original concept confirms a four-section portrait layout with two active falling-item areas and bottom electric-line taps. The first playable uses two active lanes with fixed controls resolving the front-most eligible item.
- The first playable contains one island and level, three parameters (Hunger, Rest, Fun), touch/mouse controls, pause/restart, timer/score/best score, simple UI, basic animations, and placeholder art.
- Excludes monetization, analytics, online, social, account, shop, cosmetics, and multiple islands.

## Pending Source-Dependent Sections

The original source is to be retained at `docs/source/Wandering Tourist - Game Document.pdf` before Phase 1. Exact timer/score rules, level-completion details, parameter-edge semantics, balancing values, lane-to-parameter mapping, item-effect matrix, visual feedback, audio direction, and accessibility requirements remain open in `PHASE_0_CONCEPT_ANALYSIS.md`.

## Approved Prototype Directions

- Use Hunger, Rest, and Fun.
- Use time-limited survival with configurable duration, score, safe boundaries, and balance values.
- Use two fixed electric-line controls; retain an input boundary for future direct-tap and swipe experiments.
- Investigate a hybrid item-effect model: clear baseline items plus a small, visibly distinct set of contextual multi-parameter trade-off items.
