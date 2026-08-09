# Phase 0 — Concept Analysis

## Source Reviewed

`docs/source/Wandering Tourist - Game Document.pdf`, 8 pages, dated 2023. The canonical repository copy was SHA-256-verified against the supplied source on 2026-08-09. The visual mock-up confirms a four-section portrait layout with two confirmed active falling-item areas, a parameter HUD, two bottom electric-line controls, pause, timer, and tropical-island placeholder art.

## Phase Status

**COMPLETE.** Phase 0 is formally closed. Its remaining details are intentionally deferred to Phase 1 and prototype iteration; they are not blockers for entering Phase 1 when explicit authorization is received.

## 1. Concept Analysis

**Confirmed source evidence:** Wandering Tourist has a four-section portrait layout, two main areas containing falling positive and negative items, and bottom electric lines that players tap to cut falling items. It uses parameter management and themed-island progression.

**Approved first-playable direction:** Use exactly two active falling-item lanes with fixed bottom electric-line controls, and use Hunger, Rest, and Fun as the active parameters.

**Proposed interpretation:** The core tension can be selective attention and state-based prioritization. The PDF does not define how negative items behave, so the assertion that they destabilize parameters is a hypothesis to test, not confirmed source behavior. The original document describes themed islands and progressively added parameters; the current first-playable brief deliberately reduces that to one island and exactly three parameters.

## 2. Gameplay Loop Analysis

**Proposed prototype moment-to-moment loop:** scan falling items, assess their likely effect against current parameter state, tap the matching line at a safe moment, then reassess Hunger, Rest, and Fun.

**Approved prototype run-loop direction:** start a time-limited run, manage active parameters, accumulate a configurable score, complete the timer if still alive, record score/best score, then restart. The PDF does not confirm time-limited survival as its completion rule.

**Skill expression:** prioritization, reaction timing, and managing both low and high parameter risk. This is distinct from an endless tapper only if item identity and lane choice create meaningful decisions.

## 3. Game Systems

| System | Evidence | First-playable status |
| --- | --- | --- |
| Falling-item lanes | PDF specifies two main falling-item areas and bottom electric lines. | Required; two active lanes approved for prototype |
| Parameter HUD | PDF specifies parameter display and thresholds. | Required, limited to three parameters |
| Parameter simulation | PDF specifies start 50, -1/second, +7 for positive items, range 20-80, warnings at 30/70. Negative-item behavior is not specified. | Candidate baseline; exact semantics/configuration remain open |
| Timer, score, best score | Current brief requires all three; mock-up includes a timer. | Required; formulas are open |
| Pause/restart | Current brief and mock-up require them. | Required |
| Island theme and basic animation | Current brief and PDF require them. | Required, placeholder only |
| Extra parameters/islands | PDF describes them every five levels. | Deferred beyond first playable |
| Ads, coins, cosmetics | PDF describes them. | Explicitly excluded from first playable |

## 4. Missing Information and 5. Ambiguities

| ID | Ambiguity | Why it matters | Options | Recommendation |
| --- | --- | --- | --- | --- |
| A-001 | The PDF says three starting parameters but does not name them; its mock-up shows Hunger, Social, Hygiene. | Determines item families and HUD. | Use current brief; use mock-up trio; choose another trio. | Use Hunger, Rest, Fun because the current first-playable brief explicitly names them. |
| A-002 | Item-effect model is not defined; the PDF does not specify negative-item behavior. | The central decision loop cannot be specified or balanced. | Simple positive/negative; contextual multi-parameter; hybrid. | **Approved:** hybrid model, with approximately 70% simple single-parameter and 30% visually distinct contextual multi-parameter trade-off items. Exact ratios remain configurable. |
| A-003 | It is unclear whether a tap cuts every item in a lane, the next item, or a single chosen item. | Changes precision, control feel, and difficulty. | Whole-lane pulse; front-most item; direct item tap. | **Approved for prototype:** a fixed lane control resolves the front-most eligible item in that lane. |
| A-004 | Timer duration, score formula, and level-completion conditions are omitted. | Required for a testable run and best score. | Survival score; item-value score; hybrid. | **Partially approved:** time-limited survival; exact duration and score formula remain configurable and open. |
| A-005 | “Four sections” conflicts with “two main sections” and the mock-up's four vertical columns. | Determines layout and interaction model. | Two active lanes plus HUD/utility zones; four active lanes. | Treat only two columns as active lanes and reserve other columns for non-interactive separation/HUD until approved. |
| A-006 | The original monetization and cosmetics conflict with the first-playable scope. | Avoids accidental scope creep. | Include now; defer; remove forever. | Defer; first-playable brief is the controlling scope. |

## 6. Risks

- **Readability risk:** fast falling objects and a parameter HUD compete for portrait-screen attention.
- **Fairness risk:** an item-effect model that is hidden or ambiguous makes losses feel arbitrary.
- **Control risk:** two bottom buttons need unmistakable lane mapping and feedback to avoid accidental cuts.
- **Balance risk:** the PDF's universal -1/second decay may create impossible recovery patterns without spawn-rate and item-effect tuning.
- **Scope risk:** themed islands, five parameters, ads, coins, and cosmetics must remain out of the first playable.

## 7. Technical Risks

- Android touch latency, safe areas, and aspect ratios can undermine reaction-based gameplay; input and layout need device validation.
- A countdown and parameter decay must stop exactly while paused and handle Android background/resume predictably.
- Best-score persistence needs a local, documented storage and reset policy.
- Item resolution must be deterministic enough for balancing tests and future automated simulation.

## 8. Prototype Scope

One tropical placeholder island; one time-limited level; two active falling-item lanes; Hunger, Rest, Fun; a tested item-effect model; tap and mouse controls; pause/restart; timer/score/best score; basic animation and feedback. No additional islands/parameters, ads, coins, cosmetics, shop, analytics, online, account, or social features.

## 9. Recommended Controls

**Approved for prototype:** use two large, fixed bottom buttons/lines, one per active lane. A tap triggers a brief line pulse and resolves the front-most eligible item in that lane. Mirror the same behavior for left/right mouse clicks on the corresponding controls. This matches the PDF's electric-line concept, avoids obscuring falling objects, and suits portrait one-hand play. Keep lane input behind a dedicated interface so direct-tap and swipe experiments can replace it without rewriting item, parameter, score, or timer systems.

## 10. Alternative Controls

| Alternative | Benefit | Cost | Recommendation |
| --- | --- | --- | --- |
| Tap the falling item directly | Precise and intuitive. | Finger obscures small, fast targets. | Do not use for first prototype. |
| Swipe across a lane | Expressive cutting gesture. | Recognition errors and higher accessibility risk. | Consider only after core loop validation. |
| Four active lane buttons | Higher multitasking depth. | Exceeds the two-lane evidence and hurts readability. | Defer. |

## 11. Win/Lose Conditions

**Proposed failure rule:** a parameter leaving a configurable safe range triggers failure. The PDF says parameters must remain “between 20 and 80” to avoid losing, but does not resolve whether endpoints are safe.

**Approved prototype direction:** time-limited survival. The exact duration and completion behavior are not confirmed by the PDF and remain configurable.

**Score:** award points for correctly resolved items, with no unapproved coin economy. Exact values are a Phase 1 decision.

## 12. Parameter System Proposal

Start Hunger, Rest, and Fun at 50. The source baseline is decay of 1 point per second, a +7 change from positive items, warnings at 30/70, and loss outside 20-80. Use a data-driven definition for each parameter: identifier, label, start value, safe minimum/maximum, warning thresholds, passive rate, item-effect mapping, and visual/audio feedback. Negative items must be explicitly defined: the recommended model is that they change their tagged parameter toward the nearest unsafe boundary, enabling both starvation/exhaustion/boredom and overflow pressure.

## 13. Item-Effect Model Investigation and Balancing Proposal

Do not assume items are universally positive or negative. Phase 1 must compare:

| Model | Description | Strength | Risk |
| --- | --- | --- | --- |
| A. Simple positive/negative | One item has one directionally good or bad effect. | Fastest to read and tune. | May reduce play to color recognition. |
| B. Contextual multi-parameter trade-off | One item changes multiple parameters, such as Coffee improving Rest and slightly Fun while reducing Hunger. | Creates the meaningful question “Is this item beneficial given my current parameter state?” | Can overload a real-time reaction game. |
| C. Hybrid | Clear single-parameter baseline items plus a small, visibly distinct set of multi-parameter trade-off items. | Preserves readability while testing contextual decisions. | Requires clear visual communication. |

**Approved prototype direction:** Model C, hybrid. Use approximately 70% simple, single-parameter items and 30% contextual multi-parameter trade-off items. Trade-off items must be visually distinguishable, the first item pool must remain intentionally small and readable, and exact ratios remain configurable for testing. The design goal is for players to sometimes ask whether an item is good for their current state rather than only whether it is universally positive or negative. Do not add complexity beyond what the first prototype can communicate clearly.

Treat the PDF's numeric values as unvalidated baselines, not final balance. Instrument test runs with parameter trajectories, item spawns, taps, hits, misses, and cause of loss. Establish the desired first-run duration in Phase 1, then tune spawn cadence and effects so a player who recognizes and reacts correctly can recover from warnings, while random tapping cannot reliably win. Every value belongs in central configuration data with a rationale and test result.

## 14. Roadmap

Phase 0 is complete: the repository-relative source record is restored, the hybrid-item direction is approved, and remaining choices are formally deferred to Phase 1/prototype iteration. Phase 1 turns those choices into an executable GDD. Phase 2 defines the Godot architecture. Only then can the prototype begin.

## 15. Architecture Proposal

For Phase 2, use a data-driven composition: a game-flow coordinator; independent lane, falling-item, parameter, scoring, timer, input, persistence, and UI modules; and resource-based definitions for parameters, item types, level settings, and tuning. The lane-input boundary must allow fixed electric lines, direct tap, or swipe adapters without rewriting gameplay systems. Scenes communicate through documented signals, with no hidden cross-scene logic. This is a proposal only; no production architecture or code is approved yet.

## Phase 0 Approval Request

Phase 0 approval criteria are satisfied. Do not start Phase 1 until explicit authorization is received. The next task is to author the executable GDD only after that authorization.
