# Wandering Tourist - Executable Game Design Document

## Status

Phase 1 is complete and awaiting approval. This document specifies Prototype v0.1 only; it authorizes neither production code nor Phase 2 architecture work.

## Scope and Run Loop

Prototype v0.1 is a portrait Android 2D game with one tropical placeholder island, one level, two active falling-item lanes, Hunger/Rest/Fun, touch and mouse input, pause/restart, timer/score/best score, basic feedback, and placeholder art. Ads, currency, cosmetics, shop, online/social/account features, analytics, and additional islands or parameters are excluded.

The player survives a 120-second active run by managing the three parameters. Each lane has one fixed electric-line control. Tapping a line resolves its front-most eligible item; items outside the final 0.60-second cut window cannot resolve. Some items should be collected and some should pass. Contextual items require a decision based on current parameter state.

## Controls, Pause, and Restart

| Control | Behavior |
| --- | --- |
| Left/right line | Resolve the front-most eligible item in that lane; 0.25-second per-lane cooldown. |
| Mouse | Left-click mirrors the relevant touch control. |
| Pause | Freezes timer, decay, item motion/spawns, and resolution. |
| Restart | From pause requires confirmation; from a result starts a fresh run immediately. |

The four-section source layout contains only two confirmed active falling-item areas. Input must remain replaceable so direct-tap or swipe controls can later replace line controls without changing gameplay rules.

## Parameters and Win/Lose Rules

| Parameter | Start | Safe range | Warning | Passive change |
| --- | ---: | --- | --- | ---: |
| Hunger | 50 | 20.0 through 80.0 inclusive | <=30.0 or >=70.0 | -0.30/second |
| Rest | 50 | 20.0 through 80.0 inclusive | <=30.0 or >=70.0 | -0.30/second |
| Fun | 50 | 20.0 through 80.0 inclusive | <=30.0 or >=70.0 | -0.30/second |

Values are floating-point and never clamped. After every decay tick or item transaction, fail the run if any value is <20.0 or >80.0. Exactly 20.0 and 80.0 are safe. Win when 120 seconds of active gameplay elapse with all parameters safe. Pause/background time never counts.

## Item Matrix and Hybrid Distribution

Use a rolling 10-item bag: 7 simple single-parameter items and 3 visually distinct contextual trade-off items. Shuffle each bag. Values, ratios, and weights remain configurable. Simple items use one stat icon plus an up/down marker; trade-offs use a distinct multi-icon frame and all affected stat icons. Color is never the only meaning cue.

| Item | Type | Action | Hunger | Rest | Fun | Score |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| Fruit | Simple boost | Cut | +7 | 0 | 0 | 100 |
| Pillow | Simple boost | Cut | 0 | +7 | 0 | 100 |
| Camera | Simple boost | Cut | 0 | 0 | +7 | 100 |
| Stale snack | Simple hazard | Pass | -7 if cut | 0 | 0 | 50 when passed |
| Alarm clock | Simple hazard | Pass | 0 | -7 if cut | 0 | 50 when passed |
| Rain cloud | Simple hazard | Pass | 0 | 0 | -7 if cut | 50 when passed |
| Coffee | Trade-off | Cut when appropriate | -6 | +8 | +2 | 150 when cut |
| Local meal | Trade-off | Cut when appropriate | +8 | -4 | +2 | 150 when cut |
| Night market | Trade-off | Cut when appropriate | -3 | -5 | +9 | 150 when cut |

The small pool is intentional. Its goal is to make players sometimes ask whether an item benefits their current state, not merely whether it is positive or negative.

## Spawn and Motion

| Setting | Default | Rule |
| --- | ---: | --- |
| Global spawn interval | 1.40 seconds | Delay 0.20 seconds if both lanes are full. |
| Lane selection | Fair random | No lane receives more than two consecutive spawns; lanes are not parameter-locked. |
| Lane capacity | 2 active items | Redirect to the other lane when possible. |
| Fall duration | 3.20 seconds | Spawn-to-line travel time. |
| Reference speed | 312.5 logical px/s | Derived from a 1,000 logical-pixel lane; preserve fall duration on actual layout. |
| Cut window | 0.60 seconds | Front-most eligible item only. |

Log bag composition, lane selection, saturation, and item outcomes during prototype testing.

## Scoring and Best Score

Score is the sum of item events in the matrix plus 500 for completing the timer. Cutting a hazard, missing a boost/trade-off, or tapping with no eligible item gives zero points. Store Best locally at the end of any run only when final score strictly exceeds the saved Best. Failed runs may set Best; the completion bonus makes successful runs more valuable. Restart cannot update Best.

## Warning, Feedback, and Accessibility

On entering a warning band, show a parameter pattern/icon state and gentle pulse, play one cue, then play at most one reminder every five seconds while the parameter remains in that band. Exiting resets the reminder. Valid cuts pulse the line and animate the item; item results show signed deltas for every affected parameter. Failure freezes the run and names the cause; win shows completion and score.

- All item/parameter meanings use icons, shape/pattern, direction, and text where needed in addition to color.
- Controls have at least 48 dp targets; pause is always visible and works with touch/mouse.
- Support mute and sound-effects volume; no critical state is audio-only.
- A reduced-motion option replaces pulses with static high-contrast states.
- Verify readability/reachability on one small and one large portrait Android viewport.

## Prototype Balancing Table

| Setting | Default | Rationale |
| --- | ---: | --- |
| Active run duration | 120s | Supports repeated reaction tests. |
| Start value | 50 | Centered state. |
| Passive decay | -0.30/s | Creates lower-bound pressure in a short run. |
| Safe range | 20.0-80.0 inclusive | Predictable warning buffer. |
| Simple effects | +/-7 | Retains PDF positive-item baseline. |
| Trade-off benefits/costs | +8 to +9 / -3 to -6 | Meaningful but readable state trade-offs. |
| Spawn cadence | 1.40s | Roughly 85 items before delays. |
| Hybrid bag | 7 simple / 3 trade | Approved baseline. |
| Fall/cut/cooldown | 3.20s / 0.60s / 0.25s | Initial touch reaction target. |
| Completion bonus | 500 | Rewards survival. |

All defaults are configurable, not permanent truths. Changes require a documented hypothesis and test result.

## Measurable Acceptance Criteria

| ID | Pass condition |
| --- | --- |
| AC-01 | Active timer completes in 120.0 +/- 0.5 seconds; pause/background time does not count. |
| AC-02 | Logged parameter math matches decay/matrix; failure occurs only after <20.0 or >80.0. |
| AC-03 | Each complete 10-item bag contains 7 simple and 3 trade items; no lane has more than two consecutive spawns. |
| AC-04 | A valid tap resolves only the front-most eligible item; invalid taps change neither score nor parameters. |
| AC-05 | At least 4 of 5 testers identify all effects of each trade-off item after a short reference explanation. |
| AC-06 | At least 3 of 5 observed sessions include a player explaining a choice using current parameter state. |
| AC-07 | No more than 1 of 5 sessions reports an unavoidable unreadable-overlap or hidden-effect loss. |
| AC-08 | Testers distinguish warning/item meaning without relying only on color or audio. |
| AC-09 | Best persists across restart and changes only for a strictly higher final score. |

## Phase Gate

No open design question blocks Phase 1. Runtime validation and balance iteration belong to Phase 3. Do not begin Phase 2 until this GDD receives explicit approval.
