# Awan iOS Design

This document is the project-level product and architecture reference for humans and coding agents. It adapts the consolidated Awan MVP Product Specification v1.0 (14 July 2026) to the current iOS repository.

## Product Summary

Awan (أوان) is a native, AI-assisted adaptive scheduling app for goals and tasks. It is designed for people affected by schedule fragility and planning paralysis, especially students, learners, busy professionals, and freelancers.

Traditional calendars require the user to repair the day manually after a missed task. Awan instead drafts a realistic plan, detects conflicts immediately, proposes recovery choices, and keeps the user in control of every material reschedule.

Core promise:

```text
The system drafts; the user approves.
```

## Product Boundaries

### MVP Core

- Email/password authentication and OAuth sign-in.
- First-run preferences: working hours, daily zones, and maximum focus-session length.
- Four editable default zones: Study, Work, Play, and Personal.
- Natural-language goal creation with clarifying questions.
- AI-generated ordered tasks with duration, priority, zone, dependencies, and optional task deadline.
- Manual task and goal creation.
- Deterministic on-device scheduling and immediate conflict detection.
- Intelligent Nudges: Skip, Double Up, Reschedule, or Approve.
- Task completion, missed-task tracking, and daily/weekly/monthly recurrence.
- Morning and end-of-day summaries, reminders, and nightly recovery.
- Offline-first local persistence and cloud synchronization.

### Should-Have Scope

- Split long tasks across multiple sessions.
- Custom zones and zone capacity limits.
- Zone-window editing with undo/apply behavior.
- Goal progress, deadline-risk warnings, cross-device updates, ranked recovery suggestions, and reschedule history.

### Explicitly Deferred

- Social connections, marketplace, challenges, and shared goals.
- Personal/public schedule templates and RAG re-templating.
- GitHub, Strava, and photo verification.
- Self-hosted or fully on-device AI.
- Writable calendar integration, voice goal creation, widgets, Live Activities, and advanced insights.

## Hybrid Intelligence Boundary

Awan separates semantic interpretation from deterministic scheduling.

### Cloud AI Architect

The backend receives raw goal text and minimal context, asks clarifying questions when needed, and returns a strict versioned JSON contract. It may choose task semantics, ordering, estimates, dependencies, priority, and zone.

It must not:

- Produce task start times.
- Perform overlap or free-slot calculations.
- Silently reschedule the user's calendar.

### On-Device Local Conflict Engine

The pure-Swift engine consumes the validated contract plus local schedule state. It owns:

- Dependency validation and topological ordering.
- Overlap detection.
- Zone-constrained free-slot calculation.
- Deterministic task placement and optional splitting.
- Immediate conflict proposals.
- Nightly recovery and cascading dependent-task movement.

It must not infer what the user meant or invent tasks.

### Contract Direction

```text
User goal text
-> backend /v1/parse
-> validated JSON task breakdown
-> Data mapping
-> Domain decomposition
-> Local Conflict Engine
-> proposed schedule
-> user approval
-> local persistence
-> background sync
```

Freeze and version the JSON contract. Treat incompatible changes as breaking across backend, iOS, Android, and QA test vectors.

## Repository Architecture

The repository uses layer-first Clean Architecture. Each layer is a Swift package under `Modules/`; features are folders repeated inside those packages.

### `Modules/Common`

Stable cross-cutting code with no feature-specific business rules.

Current responsibility:

- Shared coordinator contract.

Expected responsibility:

- Design-system tokens and reusable UI primitives.
- Stable utilities used by multiple packages.
- Shared test helpers only when they are truly cross-package.

### `Modules/Domain`

The center of the architecture.

Owns:

- `Goal`, `ScheduledTask`, `DailyZone`, recurrence, priority, deadlines, and schedule value objects.
- Repository protocols.
- Use cases and business validation.
- Pure-Swift Local Conflict Engine.
- Domain errors and scheduling outcomes.

Domain must remain independent of SwiftUI, Observation, SwiftData/Core Data, URLSession, transport DTOs, and DI frameworks.

### `Modules/Network`

Transport and remote API infrastructure.

Owns:

- REST client and endpoint definitions for `/v1/parse`, `/v1/sync`, and `/v1/auth/*`.
- Request/response DTOs and decoding.
- Authentication/header and transport-error behavior.
- Retry/cancellation policy at the HTTP boundary.

Network does not decide business behavior and does not return Domain entities.

### `Modules/Data`

Concrete data access and reconciliation.

Owns:

- Implementations of Domain repositories.
- Remote and local data sources.
- SwiftData/Core Data persistence models and queries.
- DTO/persistence-to-Domain mapping.
- Offline mutation queue and synchronization actor.
- Last-Write-Wins reconciliation using server-assigned timestamps for the MVP.

The local store is the UI source of truth. Remote responses update local state; Presentation does not render transport DTOs directly.

### `Modules/Presentation`

SwiftUI and app interaction.

Owns:

- `@Observable`, `@MainActor` view models.
- Explicit screen states and user intents.
- SwiftUI screens and feature components.
- `AppCoordinator`, `AuthCoordinator`, `MainCoordinator`, and typed route enums.

Presentation depends on Domain abstractions and Common UI primitives. It does not import concrete Data repositories or Network DTOs.

### `Awan` App Target

The executable is the composition root. It constructs concrete dependencies, injects them into Presentation, configures persistence/background tasks, and hosts the root coordinator.

The current SwiftData `Item` model and empty auth/main destinations are scaffolding, not product-domain design.

## Dependency Direction

```text
Awan app (composition root)
|-- Presentation --> Domain
|-- Data ---------> Domain
|   `-------------> Network
|-- Network
|-- Domain
`-- Common

Common supplies stable shared utilities without owning feature behavior.
```

No lower layer imports Presentation. Domain imports no other local architecture layer.

## Core Scheduling Behavior

### Overlap

Two half-open intervals overlap when:

```text
startA < endB && startB < endA
```

### Dependency Resolution

Build a DAG from task dependencies and run Kahn's algorithm. Reject the decomposition when nodes remain after the sort.

### Placement

For each zone, subtract busy intervals from the zone window. Walk tasks in topological order, breaking eligible ties by priority and earliest deadline, and choose the earliest sufficiently large valid slot. Split only when the task is splittable and product rules allow it.

### Recovery

The nightly sweep drafts recovery for incomplete tasks. Independent tasks past their valid window may be dropped guilt-free; tasks with dependents or future deadlines move to the next valid slot and cascade. Material changes become an Intelligent Nudge instead of an automatic commit.

Background execution is not guaranteed on iOS. A foreground catch-up must run whenever the last sweep is stale.

## Offline And Sync Model

```text
SwiftUI
-> ViewModel
-> Domain use case
-> Domain repository contract
-> Data repository implementation
-> local data source (truth)
-> sync queue
-> Network client
-> backend
```

Local mutations are immediately visible and marked pending. Sync flushes them when connectivity returns, applies server state, and reconciles the local store. Records carry identity, user ownership, server update time, and sync status as required by the frozen contract.

## Navigation

The current app has an `AppCoordinator` that switches between auth and main flows. `AuthCoordinator` and `MainCoordinator` own `NavigationPath` and typed routes.

Keep navigation coordinator-owned:

- A feature view emits an intent or uses an injected navigation callback.
- A coordinator translates that intent into a route.
- Views and Domain types do not mutate unrelated navigation stacks.

## Open Product Decisions

Do not silently invent these values; record the product decision when a ticket resolves one:

- Exact LLM provider/model behind the backend abstraction.
- Whether maximum focus duration is global-only or task-overridable.
- Recurrence end rules.
- OAuth provider set.
- Default zone time windows.
- Account deletion/data-retention behavior.
- Minimum OS/localization policy beyond the repository's current iOS 18 package setting.
- Monetization model.

## Key Engineering Risks

- JSON contract churn: version it and use shared fixtures.
- iOS background nondeterminism: always implement foreground catch-up.
- Malformed or semantically poor AI output: validate server-side and preserve a deterministic fallback.
- Android/iOS engine divergence: share test vectors and require identical outcomes.
- Scope creep: treat the deferred feature families as a firm boundary.
