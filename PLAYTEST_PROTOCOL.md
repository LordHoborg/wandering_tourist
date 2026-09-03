# Playtest Protocol — Phase 4 Human Acceptance Criteria

This protocol produces the evidence for the six acceptance criteria the automated
balance harness cannot cover: **AC-05, AC-06, AC-07, AC-08, AC-10, AC-11**
(`GAME_DESIGN_DOCUMENT.md`, Acceptance Criteria). It is the only outstanding
Phase 4 gate item; everything mechanical is already verified by TR-012.

## Ground Rules

- **Five testers**, each a **first-time** player of this prototype, tested **one at a time**.
- One facilitator + one observer (the same person may do both if notes stay reliable).
- No coaching, hints, or reactions during play. Answer questions with "play however you like."
- Do not tell testers they are being scored on replay behavior or enjoyment until the session ends.
- Record exactly what happens; interpret later.

## Setup

1. Run from source: `tools/godot/Godot_v4.7.1-stable_win64.exe --path .`
2. Before each tester, reset persisted state (delete the best-score save file) so
   every tester gets a clean first-run experience.
3. Confirm reduced-motion and mute are at defaults unless a tester requests otherwise.
4. Have the recording sheet (below) ready, one per tester.

## Session Script (per tester, ~20–30 min)

### Step 1 — Reference explanation (AC-05 setup, ~2 min)

Give the short control/item reference explanation required by the GDD:
show the controls (fixed lane taps), show each trade-off item icon, and state
each item's effect once, in neutral terms. Do not advise strategy.

### Step 2 — Uninterrupted first run (~5–10 min)

- Let the tester play the full fifteen-level campaign (or until a loss) without interruption. Pay special attention to the Social unlock at level 6 and Hygiene unlock at level 11.
- Record whether the player reads the pre-level story briefings, understands why meter rhythms differ, and notices `WAIT` before triggering a risky item sequence.
- Observer logs:
  - Any moment the tester appears confused by what an item will do.
  - Any loss or near-loss — and whether the tester could see/read the cause
    (feeds AC-07).
  - Any moment the tester verbalizes *why* they took or skipped an item
    (feeds AC-06). Note the exact words if they reference current parameter state
    (e.g. "my hunger is low so I need the food even though...").

### Step 3 — Result screen, 30-second silent observation (AC-10)

- Present the normal result screen. Say nothing for 30 seconds.
- Record whether the tester **voluntarily starts a second run without prompting**.
  Yes/No. If they ask "should I play again?", answer "up to you" — that still
  counts as voluntary only if they then choose to replay.

### Step 4 — Item-effect quiz (AC-05)

- Show each trade-off item icon one at a time; ask "what does this do?"
- Mark each item correct/incorrect. "Identifies all effects of each trade-off
  item" = all trade items correct for that tester.

### Step 5 — Short interview (AC-06, AC-07, AC-08)

Ask, in order:
1. "Tell me about a choice you made during a run — why did you pick that?"
   (AC-06: does the reasoning cite current parameter state?)
2. "Was there any moment you lost or got hurt and couldn't tell why, or couldn't
   read what was on screen?" (AC-07: unavoidable unreadable-overlap or
   hidden-effect loss.)
3. "How did you tell warnings and items apart?" (AC-08: pass only if the answer
   uses shape/icon/position/motion — not color or audio alone.)

### Step 6 — Private enjoyment rating (AC-11)

- After the replay observation is complete, collect a **private** 1–5 enjoyment
  rating of the core gameplay plus one optional reason. Private = written or
  entered by the tester, not spoken to the facilitator.

## Recording Sheet (copy per tester)

```
Tester #: ___   Date: ______   First-time player: Y/N

AC-10  Voluntary replay within 30s of result screen:        Y / N
AC-05  Trade-item effects all correct (quiz):               Y / N   (missed: ______)
AC-06  Explained a choice using current parameter state:    Y / N   (quote: ______)
AC-07  Unreadable-overlap or hidden-effect loss reported:   Y / N   (detail: ______)
AC-08  Distinguishes warning/item without color-audio only: Y / N   (cues used: ______)
AC-11  Enjoyment rating (1-5): ___   Optional reason: ______
```

## Pass/Fail Tally

| Criterion | Pass rule |
| --- | --- |
| AC-05 | ≥ 4 of 5 testers identify all trade-item effects |
| AC-06 | ≥ 3 of 5 sessions include parameter-state reasoning |
| AC-07 | ≤ 1 of 5 sessions reports an unavoidable unreadable-overlap or hidden-effect loss |
| AC-08 | Testers distinguish warning/item meaning without relying only on color or audio |
| AC-10 | ≥ 4 of 5 voluntarily start a second run |
| AC-11 | ≥ 4 of 5 rate enjoyment ≥ 3/5 **and** ≥ 2 of 5 rate ≥ 4/5 |

## Reporting

Record the completed tally as **TR-013** at the top of `TEST_REPORT.md`, using
this template:

```
## TR-013 - Phase 4 Human Playtest (AC-05..AC-08, AC-10, AC-11)

- **Date:** <date(s) of sessions>
- **Scope:** Five first-time testers, protocol in PLAYTEST_PROTOCOL.md.
- **Method:** Reference explanation, one uninterrupted run, 30s replay
  observation, item-effect quiz, structured interview, private enjoyment rating.
- **Results:** AC-05 _/5, AC-06 _/5, AC-07 _/5 incidents, AC-08 pass/fail,
  AC-10 _/5, AC-11 ratings [_, _, _, _, _] → each criterion PASS/FAIL.
- **Regression check:** Balance harness re-run after any tuning (13/13 required).
- **Follow-up:** Balance changes demanded by the playtest, or "none".
```

## After the Playtest

1. For every failed criterion, write a **hypothesis** (what to change and why it
   should move that specific criterion) before touching balance values.
2. Apply the change, re-run the full automated suite — the TR-012 balance
   harness must stay 13/13 — then re-test only the failed criteria with fresh
   first-time testers.
3. Update `TODO.md`, the roadmap, and the master document checkpoint when all
   six criteria pass; Phase 4 then closes and Phase 5 (Vertical Slice) opens.
