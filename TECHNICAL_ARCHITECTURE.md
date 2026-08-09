# Technical Architecture

## Status

Draft placeholder. Technical architecture is a Phase 2 deliverable and must be informed by the approved GDD.

## Confirmed Technology Constraints

- Godot 4 latest stable/LTS.
- Typed GDScript.
- Android portrait target.
- 2D rendering.
- Modular, maintainable, documented architecture.
- Gameplay values will reside in configurable resources or centralized data files.

## Deferred Design

Scenes, scripts, resources, autoloads, signals, save strategy, UI composition, test approach, and Android export configuration are intentionally deferred until approved design and architecture phases. Input mapping must preserve a replaceable lane-input boundary so fixed controls, direct tap, and swipe can be tested without rewriting gameplay systems.
