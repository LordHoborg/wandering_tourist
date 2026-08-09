# Phase 0 — Concept Analysis

## Status

**Blocked pending original concept PDF.** The supplied brief names a PDF as the original vision, but no PDF was attached or found in the supplied attachment set. The sections below separate confirmed requirements from unconfirmed design questions; they are not a replacement for analysis of the original vision.

## 1. Confirmed Concept Scope

Wandering Tourist is planned as a portrait Android 2D game in Godot 4. The first playable must focus on a single island and one gameplay loop with three named parameters: Hunger, Rest, and Fun. Its purpose is to validate whether the gameplay is fun, not to establish monetization or a broad content platform.

## 2. Gameplay Loop Analysis

The actual loop is **unknown**. The brief does not state what the player does to change Hunger, Rest, or Fun; how a turn, timer, or day progresses; or what creates trade-offs. These rules determine whether the game is real-time, turn-based, task-based, or simulation-driven.

| Ambiguity | Why it matters | Alternatives | Recommendation | Status |
| --- | --- | --- | --- | --- |
| Core player action | Determines controls, scene structure, and fun hypothesis. | Tap locations; drag avatar; select actions; hybrid. | Derive from the PDF, then validate one low-complexity loop in prototype. | OPEN |
| Time model | Controls parameter decay, tension, and pause behavior. | Real-time; discrete turns; activity time costs. | Derive from the PDF. | OPEN |
| Primary objective | Defines score and success state. | Survive duration; complete itinerary; maximize satisfaction; reach location. | Derive from the PDF. | OPEN |

## 3. Game Systems

Only these systems are confirmed: parameter display/updates, controls, pause/restart, timer, score, best score, basic UI/animation, and an island/level container. Interaction, movement, economy, events, inventory, NPCs, progression, save behavior, and audio are unconfirmed and must not be assumed.

## 4. Missing Information and 5. Ambiguities

The source PDF is the principal missing information. In addition, the brief does not establish player fantasy, camera view, island layout, activity catalog, parameter scale and decay, action costs, score formula, timer behavior, success/failure rules, best-score persistence, visual/audio direction, localization, or accessibility needs. Each is logged as open because it materially affects the executable GDD and architecture.

## 6. Risks

- **Design risk:** Building a parameter system before defining the core action can produce a disconnected UI rather than a fun loop.
- **Scope risk:** “One island” can still become too large without an activity and time budget.
- **Validation risk:** “Fun” has no testable success metric yet.
- **Continuity risk:** Starting implementation before source material and approval would violate the project governance.

## 7. Technical Risks

- Godot and Android export versions are not selected or verified yet.
- Device aspect-ratio, safe-area, touch-target, and performance budgets are unknown.
- Best-score persistence needs a confirmed reset and storage policy.
- The eventual parameter timing model will determine pause, lifecycle, and backgrounding behavior.

## 8. Prototype Scope

The approved maximum first-playable scope is the constraints in `GAME_DESIGN_DOCUMENT.md`. Recommended prototype guardrails, subject to the concept PDF: one playable loop, one map/scene, no unlocks, no network dependencies, no purchasable content, and placeholder assets only. Exact activities, duration, and success criteria remain open.

## 9. Recommended Controls

No control scheme can be recommended responsibly without knowing the core action. Preserve these platform requirements: portrait single-hand reachability, visible touch affordances, touch targets appropriate for Android, and equivalent mouse input for desktop testing. Choose the simplest input model that directly expresses the approved loop.

## 10. Alternative Controls

Candidate patterns awaiting the concept: direct tap-to-interact; tap to select then tap destination; drag-and-drop; virtual joystick; and discrete action buttons. Virtual joystick is generally higher UI and tuning cost and should only be selected when continuous character movement is essential to the approved concept.

## 11. Win/Lose Conditions

Unknown. The timer, score, and three parameters imply possible pressure, but they do not define a win or loss. Candidate models are duration survival, destination/itinerary completion, score threshold, or a hybrid. Official conditions must be taken from the PDF or explicitly approved.

## 12. Parameter System Proposal

Use one data-driven definition per confirmed parameter: display name, range, starting value, minimum/maximum effects, decay/change triggers, feedback thresholds, and contributing actions. Do not choose numbers or behavior until the underlying loop is confirmed. A final parameter model must specify whether zero causes failure, penalty, restricted actions, or recovery opportunity.

## 13. Balancing Proposal

After the loop is approved, establish a short target session duration and work backward from it: starting values, expected activity cadence, recovery amounts, and score opportunities. Store all values in named configuration data and record every change with hypothesis and observed test result. No numeric targets are set in Phase 0 because they would be unsupported assumptions.

## 14. Roadmap

The phase roadmap is in `ROADMAP.md`. The immediate dependency is source analysis and Phase 0 approval; only then may the executable GDD, architecture, and prototype proceed.

## 15. Architecture Proposal

Architecture is deliberately deferred to Phase 2. The only current recommendation is a modular, data-driven Godot 4 structure with typed GDScript and documented scenes, scripts, resources, autoloads, and signals. Choosing concrete modules before gameplay is approved would be speculative.

## Required Decision to Continue

Provide the original concept PDF. Then this document will be updated with traceable analysis, formal recommendations, and only those open decisions the source does not resolve. Phase 0 will end with a review, documentation test, checkpoint, and explicit approval request.
