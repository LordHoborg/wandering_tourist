# Wandering Tourist - Technical Architecture

## Status

**Phase 2 complete, awaiting approval.** This specification defines the Godot 4 architecture for Prototype v0.1. No Godot project, production scene, or gameplay script has been created.

## Architecture Decisions

| Concern | Alternatives | Decision | Reason |
| --- | --- | --- | --- |
| Global access | Many autoloads; one event bus; composition root | One `AppSettings` autoload only; composition root owns gameplay services. | Avoids hidden gameplay globals while retaining settings access. |
| State machine | Boolean flags; scene switching; explicit enum state | `RunStateMachine` with typed enum and legal transitions. | Testable pause/result behavior. |
| Data | Constants; dictionaries; Resources | Typed immutable `Resource` definitions, runtime state classes. | Inspector-editable and testable tuning. |
| Events | Direct UI calls; global bus; local typed signals | Local typed signals between direct collaborators. | Clear ownership and no broadcast coupling. |
| Input | UI-owned input; action adapter; per-control logic | `LaneInputAdapter` interface with fixed-line implementation. | Enables direct-tap/swipe experiments without gameplay rewrites. |

## Folder Tree and Naming

```text
res://
  scenes/
    app/app_root.tscn
    gameplay/gameplay_root.tscn
    gameplay/lane_view.tscn
    gameplay/item_view.tscn
    ui/hud.tscn
    ui/pause_overlay.tscn
    ui/result_overlay.tscn
  scripts/
    app/app_root.gd
    game/gameplay_coordinator.gd
    game/run_state_machine.gd
    game/timer_service.gd
    game/score_service.gd
    game/best_score_repository.gd
    game/parameter_service.gd
    game/item_resolver.gd
    game/spawn_scheduler.gd
    game/spawn_fairness_validator.gd
    game/lane_input_adapter.gd
    game/fixed_line_input_adapter.gd
    game/run_debug_logger.gd
    ui/hud_presenter.gd
    ui/pause_presenter.gd
    ui/result_presenter.gd
    data/parameter_definition.gd
    data/item_definition.gd
    data/level_definition.gd
    data/feedback_definition.gd
    state/parameter_state.gd
    state/item_instance.gd
    state/run_snapshot.gd
  resources/
    parameters/prototype_parameters.tres
    items/prototype_items.tres
    levels/prototype_level.tres
    feedback/prototype_feedback.tres
  tests/
    unit/
    integration/
  autoload/
    app_settings.gd
```

Use `snake_case` for paths, files, nodes, variables, methods, signals, and resource IDs; `PascalCase` for classes; suffix scenes with `_root`, `_view`, or `_overlay`; suffix data resources with `_definition`; suffix runtime state with `_state`. One public class per script.

## Scenes and Nodes

```text
AppRoot (Node)
  GameplayRoot (Node2D)
    GameplayCoordinator (Node)
    LaneContainer (Node2D)
      LeftLaneView (Node2D)
      RightLaneView (Node2D)
    ItemContainer (Node2D)
    GameplayHud (CanvasLayer)
  PauseOverlay (CanvasLayer)
  ResultOverlay (CanvasLayer)
```

`AppRoot` composes dependencies, owns scene navigation and lifecycle translation. `GameplayCoordinator` owns a single run and services. `HudPresenter`, `PausePresenter`, and `ResultPresenter` subscribe to coordinator-facing signals, create view-facing snapshots/events, and are the only gameplay-facing dependency of HUD/overlay views. Lane/item views render supplied state only. Views emit user intent only; they never change parameters, score, spawns, or timer directly.

## Data and Runtime State

`ParameterDefinition` contains ID, label, start/safe/warning values and decay. `ItemDefinition` contains ID, visual key, category, deltas, score rules, and spawn weight. `LevelDefinition` contains duration, lane limits, bag ratios, drought limit, spawn/fall/cut timings, neutral target, and completion bonus. `FeedbackDefinition` contains cue IDs and warning timings. Resources contain defaults only; runtime values live in `ParameterState`, `ItemInstance`, and `RunSnapshot` and are never written into resources.

## Ownership and Dependency Rules

`GameplayCoordinator` may call services and bind their signals. `ParameterService` owns parameter mutation/validation. `ItemResolver` owns transaction calculation and asks `ParameterService` to apply deltas; it never changes score. `ScoreService` owns score math and best-score candidate. `SpawnScheduler` chooses timing/lane/category; `SpawnFairnessValidator` validates/repairs candidate selection and owns no clock. `TimerService` owns active elapsed time. Views depend only on presenters/contracts, never services.

Forbidden coupling: UI-to-service mutation; item resolver-to-UI; score service-to-item nodes; spawning-to-parameter mutation; fairness-to-lane view; resource mutation at runtime; gameplay access through autoload; stringly typed signal payloads; one system reaching through another node's children.

## Signals and Event Map

| Owner | Signal | Payload | Consumers |
| --- | --- | --- | --- |
| RunStateMachine | `state_changed` | previous, current | GameplayCoordinator, presenters |
| TimerService | `time_changed`, `timer_completed` | remaining; none | GameplayCoordinator |
| ParameterService | `parameters_changed`, `warning_entered`, `failure_detected` | snapshot; ID/band; ID/value | GameplayCoordinator |
| SpawnScheduler | `item_spawn_requested` | item definition, lane ID | GameplayCoordinator/view factory/logger |
| ItemResolver | `item_resolved` | transaction result | GameplayCoordinator, score/logger/feedback |
| ScoreService | `score_changed` | score | GameplayCoordinator |
| LaneInputAdapter | `lane_activated` | lane ID | GameplayCoordinator |
| BestScoreRepository | `best_score_changed` | best | GameplayCoordinator |
| GameplayCoordinator | `hud_state_changed`, `pause_state_changed`, `result_ready` | HUD snapshot; pause snapshot; result snapshot | corresponding presenter only |
| HudPresenter/PausePresenter/ResultPresenter | view update signals | immutable view model/event | corresponding view only |

Signals are typed, documented beside declaration, and connect only in the composition root/coordinator. Services never connect directly to views; presenters never expose service objects to views.

## Game State and Data Flow

States: `IDLE -> RUNNING -> PAUSED -> RUNNING`, `RUNNING -> FAILED`, `RUNNING -> COMPLETED`, `FAILED/COMPLETED -> IDLE`. Illegal transitions are rejected and logged. On each active tick, coordinator advances timer, decay, scheduler, and item motion. Input produces a lane ID; coordinator requests the front eligible item; resolver produces a transaction; parameter service applies it and validates failure; score service consumes the final transaction result; coordinator publishes snapshots to presenters; presenters render through views. Pause freezes all active services. `AppRoot` owns Godot lifecycle notifications and translates focus/background loss into a pause intent sent to `GameplayCoordinator`, which requests the state transition. The domain never receives Android/OS/Godot lifecycle APIs; desktop tests invoke the same pause intent directly.

## Save, Settings, Debug, and Testing

`BestScoreRepository` is an injected file-backed repository using `user://`; only it reads/writes best score. `AppSettings` is the sole autoload and owns mute, SFX volume, reduced motion, and persisted settings. `RunDebugLogger` receives structured snapshots/events only in debug builds and can export deterministic seed, bag contents, lane choices, transactions, and state transitions.

Unit test services with fake clock, RNG, repository, input adapter, and logger. Cover parameter boundaries, trade-off distance scoring, bag/drought fairness, lane selection, pause clock freeze, best-score strictness, and state transitions. Integration tests use a deterministic seed to run a full 120-second simulation and assert acceptance criteria inputs. Manual Android tests cover small/large portrait layouts, pause/background behavior, touch targets, audio/mute, and reduced motion.

## Android and Export Considerations

Use portrait lock, safe-area-aware HUD margins, CanvasItem scaling from a documented reference resolution, touch-first controls, app-pause handling on focus loss, and local `user://` persistence. Configure Android package/version/signing/export only in Phase 6; no SDK, manifest, or export files are created now. Target stable Godot 4/LTS selected at project creation and record its exact version in build notes.

## Phase 3 Implementation Order

1. Create project, resources, typed data/state classes, and unit-test harness.
2. Implement run state, timer, parameters, score, repository, and tests.
3. Implement item resolver, distance scoring, bag/fairness, scheduler, and tests.
4. Build lane input adapter and headless coordinator integration tests.
5. Add minimal views/HUD/overlays and bind typed signals.
6. Add feedback, accessibility settings, debug logging, and manual test checklist.
7. Produce Prototype v0.1 checkpoint and APK preparation only after prototype acceptance review.

## Phase Gate

Phase 3 is blocked until explicit approval of this architecture.
