# Phase 0 — Concept Analysis

## Source Reviewed

`Wandering Tourist - Game Document.pdf`, 8 pages, dated 2023. The visual mock-up confirms a portrait, four-column playfield with a parameter HUD on the left, two bottom electric-line controls, pause, timer, and tropical-island placeholder art.

## 1. Concept Analysis

Wandering Tourist is a real-time multitasking game. Items fall through two gameplay lanes; the player taps an electric line at a lane bottom to cut them. The central tension is selective attention: collect beneficial items for parameters approaching their safe boundary while preventing harmful items from destabilizing them. The original document describes themed islands and progressively added parameters; the current first-playable brief deliberately reduces that to one island and exactly Hunger, Rest, and Fun.

## 2. Gameplay Loop Analysis

**Moment-to-moment:** scan falling items, identify lane/item value, tap the matching line at a safe moment, then reassess three decaying parameters.

**Run loop:** start a timed level, keep all active parameters in the safe range, accumulate score, finish the timer if still alive, record score/best score, then restart.

**Skill expression:** prioritization, reaction timing, and managing both low and high parameter risk. This is distinct from an endless tapper only if item identity and lane choice create meaningful decisions.

## 3. Game Systems

| System | Evidence | First-playable status |
| --- | --- | --- |
| Falling-item lanes | PDF specifies two main falling-item sections and bottom electric lines. | Required |
| Parameter HUD | PDF specifies parameter display and thresholds. | Required, limited to three parameters |
| Parameter simulation | PDF specifies start 50, -1/second, +7 for positive items, safe range 20-80, warnings at 30/70. | Candidate baseline; approve before implementation |
| Timer, score, best score | Current brief requires all three; mock-up includes a timer. | Required; formulas are open |
| Pause/restart | Current brief and mock-up require them. | Required |
| Island theme and basic animation | Current brief and PDF require them. | Required, placeholder only |
| Extra parameters/islands | PDF describes them every five levels. | Deferred beyond first playable |
| Ads, coins, cosmetics | PDF describes them. | Explicitly excluded from first playable |

## 4. Missing Information and 5. Ambiguities

| ID | Ambiguity | Why it matters | Options | Recommendation |
| --- | --- | --- | --- | --- |
| A-001 | The PDF says three starting parameters but does not name them; its mock-up shows Hunger, Social, Hygiene. | Determines item families and HUD. | Use current brief; use mock-up trio; choose another trio. | Use Hunger, Rest, Fun because the current first-playable brief explicitly names them. |
| A-002 | Positive and negative item outcomes are not defined. | The central decision loop cannot be specified or balanced. | Positive raises/negative lowers one parameter; negative raises a parameter toward overflow; mixed effects. | Define a compact item matrix in Phase 1; retain both lower- and upper-bound pressure. |
| A-003 | It is unclear whether a tap cuts every item in a lane, the next item, or a single chosen item. | Changes precision, control feel, and difficulty. | Whole-lane pulse; front-most item; direct item tap. | Use a lane pulse that affects the front-most eligible item; simple on mobile but preserves timing. |
| A-004 | Timer duration, score formula, and level-completion conditions are omitted. | Required for a testable run and best score. | Survival score; item-value score; hybrid. | Time-limited survival with score per correctly resolved item; exact values remain open. |
| A-005 | “Four sections” conflicts with “two main sections” and the mock-up's four vertical columns. | Determines layout and interaction model. | Two active lanes plus HUD/utility zones; four active lanes. | Treat only two columns as active lanes and reserve other columns for non-interactive separation/HUD until approved. |
| A-006 | The original monetization and cosmetics conflict with the first-playable scope. | Avoids accidental scope creep. | Include now; defer; remove forever. | Defer; first-playable brief is the controlling scope. |

## 6. Risks

- **Readability risk:** fast falling objects and a parameter HUD compete for portrait-screen attention.
- **Fairness risk:** a hidden or ambiguous item effect makes losses feel arbitrary.
- **Control risk:** two bottom buttons need unmistakable lane mapping and feedback to avoid accidental cuts.
- **Balance risk:** the PDF's universal -1/second decay may create impossible recovery patterns without spawn-rate and item-effect tuning.
- **Scope risk:** themed islands, five parameters, ads, coins, and cosmetics must remain out of the first playable.

## 7. Technical Risks

- Android touch latency, safe areas, and aspect ratios can undermine reaction-based gameplay; input and layout need device validation.
- A countdown and parameter decay must stop exactly while paused and handle Android background/resume predictably.
- Best-score persistence needs a local, documented storage and reset policy.
- Item resolution must be deterministic enough for balancing tests and future automated simulation.

## 8. Prototype Scope

One tropical placeholder island; one timed level; two active falling-item lanes; Hunger, Rest, Fun; defined positive/negative item families; tap and mouse controls; pause/restart; timer/score/best score; basic animation and feedback. No additional islands/parameters, ads, coins, cosmetics, shop, analytics, online, account, or social features.

## 9. Recommended Controls

Use two large, fixed bottom buttons/lines, one per active lane. A tap triggers a brief line pulse and resolves the front-most eligible item in that lane. Mirror the same behavior for left/right mouse clicks on the corresponding controls. This matches the PDF's electric-line concept, avoids obscuring falling objects, and suits portrait one-hand play.

## 10. Alternative Controls

| Alternative | Benefit | Cost | Recommendation |
| --- | --- | --- | --- |
| Tap the falling item directly | Precise and intuitive. | Finger obscures small, fast targets. | Do not use for first prototype. |
| Swipe across a lane | Expressive cutting gesture. | Recognition errors and higher accessibility risk. | Consider only after core loop validation. |
| Four active lane buttons | Higher multitasking depth. | Exceeds the two-lane evidence and hurts readability. | Defer. |

## 11. Win/Lose Conditions

**Lose:** any active parameter leaves the inclusive safe range of 20-80. This follows the PDF but needs approval that exactly 20 and 80 are still safe.

**Win:** remain in range until the level timer reaches zero. The PDF does not specify a timer length or completion rule; the proposed rule makes the current brief's timer meaningful and keeps the run finite.

**Score:** award points for correctly resolved items, with no unapproved coin economy. Exact values are a Phase 1 decision.

## 12. Parameter System Proposal

Start Hunger, Rest, and Fun at 50. The source baseline is decay of 1 point per second, a +7 change from positive items, warnings at 30/70, and loss outside 20-80. Use a data-driven definition for each parameter: identifier, label, start value, safe minimum/maximum, warning thresholds, passive rate, item-effect mapping, and visual/audio feedback. Negative items must be explicitly defined: the recommended model is that they change their tagged parameter toward the nearest unsafe boundary, enabling both starvation/exhaustion/boredom and overflow pressure.

## 13. Balancing Proposal

Treat the PDF numbers as an unvalidated baseline, not final balance. Instrument test runs with parameter trajectories, item spawns, taps, hits, misses, and cause of loss. Establish the desired first-run duration in Phase 1, then tune spawn cadence and effects so a player who recognizes and reacts correctly can recover from warnings, while random tapping cannot reliably win. Every value belongs in central configuration data with a rationale and test result.

## 14. Roadmap

Phase 0 ends after decisions A-001 through A-005 and the proposed win/loss model are approved or amended. Phase 1 turns those choices into an executable GDD. Phase 2 defines the Godot architecture. Only then can the prototype begin.

## 15. Architecture Proposal

For Phase 2, use a data-driven composition: a game-flow coordinator; independent lane, falling-item, parameter, scoring, timer, input, persistence, and UI modules; and resource-based definitions for parameters, item types, level settings, and tuning. Scenes communicate through documented signals, with no hidden cross-scene logic. This is a proposal only; no production architecture or code is approved yet.

## Phase 0 Approval Request

Approve or amend the recommendations for A-001 through A-005, the proposed loss boundaries, and time-limited survival completion. On approval, Phase 0 can be checkpointed as complete and Phase 1 can author the executable GDD.
