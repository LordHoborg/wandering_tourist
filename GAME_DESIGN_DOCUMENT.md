# Wandering Tourist - Executable Game Design Document

## Status

Phase 1 is complete and awaiting approval. This document specifies Prototype v0.1 only; it authorizes neither production code nor Phase 2 architecture work.

## Scope and Run Loop

The original Prototype v0.1 scope was a portrait Android 2D game with one tropical placeholder island, one level, two active falling-item lanes, Hunger/Rest/Fun, touch and mouse input, pause/restart, timer/score/best score, basic feedback, and placeholder art. The later PDF-aligned campaign now adds a local coin economy without external monetization: coins are earned through play, optional reward-equivalent challenges, and bonus bubbles, then spent on local tourist cosmetics.

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

### Item-Family Recovery Fairness

Every complete 10-item bag must contain at least one recovery opportunity for Hunger, Rest, and Fun. A recovery opportunity is any simple boost or contextual item with a positive effect for that parameter. The configurable maximum recovery drought is 6 spawned items: no parameter may go more than 6 consecutive spawns without a recovery opportunity. When a prospective spawn violates this limit, replace it with a valid item from the current bag while preserving lane randomness; lanes remain non-parameter-locked.

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

Score is the sum of item events in the matrix plus 500 for completing the timer. Cutting a hazard, missing a boost/trade-off, or tapping with no eligible item gives zero points. For a cut trade-off item, calculate `BeforeDistance = abs(Hunger-50)+abs(Rest-50)+abs(Fun-50)` immediately before applying it and `AfterDistance` immediately after. Award +150 only when the transaction does not fail the run and `AfterDistance < BeforeDistance`; otherwise award 0. This deterministic, configurable neutral target makes contextually beneficial trade-offs score differently from harmful ones. Store Best locally at the end of any run only when final score strictly exceeds the saved Best. Failed runs may set Best; the completion bonus makes successful runs more valuable. Restart cannot update Best.

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
| AC-10 | In a five-person first-time test, at least 4 testers voluntarily start a second run after their first result, without prompting. |
| AC-11 | In that same test, at least 4 testers rate core gameplay >=3/5 for enjoyment and at least 2 rate it >=4/5. |

For AC-10 and AC-11, give each tester one short control/item reference explanation, allow one uninterrupted first run, present the normal result screen, and observe for 30 seconds without suggesting replay. Record voluntary replay before collecting a private 1-5 enjoyment rating and one optional reason. These are prototype indicators, not production KPIs.

## Phase Gate

No open design question blocks Phase 1. Runtime validation and balance iteration belong to Phase 3. Do not begin Phase 2 until this GDD receives explicit approval.

## Playable Progression Extension

The PDF-aligned playable campaign now introduces its vocabulary over fifteen sequential levels while preserving the approved 20-80 survival bounds, item effects, lane controls, cut window, and fairness rules. Levels 1-5 establish Fruit, Pillow, Camera, then hazards and contextual H/R/F trade-offs. Level 6 activates Social and introduces Friends, Awkward, Street Festival, and Group Tour choices. Level 11 activates Hygiene and introduces Soap, Muddy, Spa Day, and the full five-need decision space. Levels increase duration and spawn pressure gradually, while rotating through tropical, neon-city, countryside, ancient-ruins, and crystal-isles destination presentations. Once trade-offs unlock, the rolling bag remains seven simple items plus three contextual items.

Item familiarity is profile-local for the active campaign and per item ID: the first encounter is NEW, encounters two through five are LEARNING, and later encounters are KNOWN. Simple-item action labels are not permanent; early exposure shows effects, while trade-offs always show their signed effects. Travel Spirit is a non-survival performance meter: correct simple cuts, hazard passes, and contextually beneficial trade-offs build it and grant a small score bonus; missed beneficial items and poor choices reduce it. Completion results report decision statistics, rating, and N advances to the next level; R retries only the current level, while the final level starts a fresh journey.

## Narrative Briefings and Need Rhythms

Every level begins with a blocking full-screen story/tutorial briefing. Text enters vertically in sequence and the run timer does not begin until the player continues. The fifteen chapters follow Milo, a curious but self-neglecting tourist, and introduce mechanics in play order. Levels 6 and 11 explicitly narrate arrival at new islands and explain the Social and Hygiene meters.

Parameters no longer decay in synchrony. Each stage provides a baseline pressure multiplied per need: Hunger 3.00, Rest 2.15, Fun 1.55, Social 0.72, and Hygiene 0.48. This makes food the most urgent routine, sleep and entertainment medium-term needs, and Social/Hygiene slower strategic needs.

## Recent-Item Sequence Rules

From level 3 onward, the last collected item and elapsed time can modify the next item's effective deltas. Double Coffee (Coffee after Coffee within 10s), Too Much Food (Night Market after Local Meal within 12s), No Sleep Tour (Group Tour after Night Market within 14s), and Crowd Overload (Street Festival after Group Tour within 12s) apply additional penalties. The item card must show `WAIT` and preview merged deltas while a rule is active; reduced-motion mode preserves all information without entrance animation.

## Coin Economy

The source PDF's income mechanism is represented as a deterministic local economy. A persistent wallet stores balance, lifetime earnings, cosmetic ownership, and the equipped look. Golden Coconuts award 15 coins, while staged bonus bubbles rotate through three readable reward types: yellow bubbles award 50 coins, green bubbles center every active need, and blue bubbles move the run clock forward by 8 seconds. Bonus bubbles are additional spawns and never replace the scheduled item needed for campaign balance.

Before a level, the player may arm an optional clean-run challenge. A successful clear with no harmful cuts and at most one missed helpful item doubles that level's coin payout. After a clear, the player may claim a second equal payout once. These controls are local equivalents of the PDF's optional rewarded-ad hooks; no ad SDK, account system, or network dependency is included in the playable build.

Coins are spent in Milo's Coin Closet on three cosmetic looks: Neon Shades, Scarlet Scarf, and Postcard Aura. Cosmetics are presentation-only, persist across sessions, and never change survival values or score.
