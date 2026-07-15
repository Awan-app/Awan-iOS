# Awan iOS Agent Instructions

This file is the repository-level source of working instructions for Codex, Antigravity CLI, and other agents that support `AGENTS.md`. Read `Design.md`, `Layers/Agent.md`, and `Modules/UI_MODULE_STRUCTURE.md` before architecture-level work.

## First Moves

Before editing:

- Run `git status --short` and preserve unrelated or uncommitted user changes.
- Confirm the active branch and fetch the latest remote state.
- Inspect the relevant `Package.swift` and nearby files before choosing a pattern.
- Prefer `rg` and `rg --files` for repository search.
- Keep changes scoped to the active Jira ticket.
- Do not edit generated build artifacts, `.build`, `.swiftpm`, `DerivedData`, `xcuserdata`, or secrets.

For ticketed work, create the branch before modifying project files.

## Git, Jira, Commit, And PR Naming

Jira development linking depends on the issue key being present in Git activity. Use the key in the branch name, commit subject, and pull request title.

- Branch from the latest `development` unless the task explicitly requires another base.
- Feature branch: `feature/AWAN-<number>-short-description`.
- Commit subject: `AWAN-<number>: imperative summary`.
- Pull request title: `AWAN-<number>: imperative summary`.
- Feature pull requests target `development`.
- Promote `development` to `main` through a separate pull request.
- Open pull requests as ready for review unless the user explicitly asks for a draft.
- Never push feature work directly to `main` or `development`.
- Do not rebase a shared long-lived branch. Merge `main` into `development` when a direct change to `main` must be carried back.

Example:

```text
feature/AWAN-25-agent-guidance
AWAN-25: add project agent guidance
AWAN-25: Add project agent guidance
```

## Product Contract

Awan is a native iOS, AI-assisted adaptive scheduling app for goals and tasks. Its promise is fluid adaptation without guilt or manual schedule repair: the system drafts and the user approves.

The architecture is intentionally split:

- The cloud AI Architect interprets intent and returns a strict, ordered task breakdown.
- The on-device Local Conflict Engine performs all time placement, overlap detection, dependency ordering, and schedule recovery.
- The AI must never choose start times or perform calendar math.
- The Local Conflict Engine must never infer user intent.
- The versioned JSON contract is the only boundary between those responsibilities.

The iOS app is offline-first. Local persistence is the source of truth, the UI observes local state, and remote synchronization reconciles in the background.

## Project Shape

This repository uses layer-first Clean Architecture with Swift Package Manager modules:

```text
Modules/
|-- Common
|-- Network
|-- Data
|-- Domain
`-- Presentation
```

Features are vertical folders repeated inside these layer packages. Do not create a new Swift package per feature unless the architecture is intentionally changed.

Preferred dependency direction:

```text
Awan app composition root
|-- Presentation -> Domain + Common
|-- Data -> Domain + Network
|-- Network
|-- Domain
`-- Common
```

Rules:

- `Domain` contains entities, value objects, repository contracts, use cases, validation, and the pure-Swift Local Conflict Engine.
- `Data` implements Domain repositories, owns local/remote data sources, persistence models, sync queues, and mapping.
- `Network` owns transport, endpoint definitions, authentication headers, request/response DTOs, and decoding concerns. It does not expose DTOs to Domain or Presentation.
- `Presentation` owns SwiftUI, `@Observable` view models, UI state, coordinators, and routes. It depends on Domain abstractions rather than Data implementations.
- `Common` holds stable, genuinely cross-layer utilities and reusable UI primitives. It is not a dumping ground for feature logic.
- The `Awan` app target is the composition root. Use constructor injection. Do not introduce Swinject or another DI framework without an explicit decision.

## Swift And Concurrency Conventions

- Use Swift 6 and honor strict concurrency diagnostics.
- Use SwiftUI and the Observation framework for new presentation code.
- Mark UI-facing view models and coordinators `@MainActor`.
- Prefer immutable `struct` models and `Sendable` protocols/values across async boundaries.
- Keep repositories, use cases, data sources, and the conflict engine off the main actor unless UI isolation is intentionally required.
- Prefer `async`/`await`; model cancellation and errors explicitly.
- Avoid force unwraps and `try!` in new code except for a proven programmer-invariant at the composition root.
- Avoid global mutable state and new singletons.
- Keep APIs internal by default; expose only what another package or the app target genuinely needs.
- Use protocols at architectural boundaries, not for every concrete type.

## Naming Conventions

- Feature folders use domain nouns: `Goals`, `Tasks`, `Schedule`, `Zones`, `Authentication`, `Sync`.
- Domain entity: noun, for example `Goal`, `ScheduledTask`, `DailyZone`.
- Use case: verb plus noun plus `UseCase`, for example `CreateGoalUseCase`.
- Repository contract: `<Feature>Repository`, for example `GoalRepository`.
- Repository implementation: `Default<Feature>Repository` unless a more specific backend name improves clarity.
- Data source: `<Source><Feature>DataSource`, for example `RemoteGoalDataSource` or `SwiftDataGoalDataSource`.
- Transport model: suffix with `RequestDTO` or `ResponseDTO`.
- Mapper: `toDomain()` and explicit initializers/extensions in Data; never add transport mapping to Domain entities.
- View: `<Screen>View`; view model: `<Screen>ViewModel`; UI state: `<Screen>State`.
- Coordinator: `<Flow>Coordinator`; route: `<Flow>Route`.
- Test files mirror the production type: `<TypeName>Tests.swift`.

## Core Scheduling Rules

- Represent task dependencies as a directed acyclic graph and reject cycles.
- Detect interval overlap with `startA < endB && startB < endA`.
- Place tasks only inside their assigned zone window.
- Resolve dependency order before placement; break eligible ties by priority, then earliest deadline.
- Never silently commit a material reschedule. Present an Intelligent Nudge and require user approval.
- Treat background execution as opportunistic. Run a foreground catch-up when the nightly sweep is stale.
- Respect iOS's pending local-notification limit; do not enqueue an unbounded reminder set.
- Keep the conflict engine deterministic, Foundation-only where practical, and independently unit-testable.
- Preserve byte-equivalent behavior with the shared Android/iOS test-vector contract.

## Data And Offline-First Rules

- The local database is the source of truth for UI reads.
- UI writes are optimistic local mutations that are queued for synchronization.
- Keep persistence models inside Data; map them to Domain entities.
- Each synchronizable record must support server identity, server-assigned update time, user identity, and sync state (`clean`, `pending`, or `conflicted`) as required by the frozen API contract.
- MVP reconciliation uses server timestamps with Last-Write-Wins unless the product contract changes.
- Never leak authentication tokens, headers, user data, or raw secrets into logs, tests, fixtures, screenshots, comments, or documentation.

## Presentation And Navigation Rules

- Keep SwiftUI views declarative and move async decisions to `@MainActor` view models.
- Model loading, content, empty, and failure states explicitly.
- Inject use cases through initializers; views must not construct repositories or network clients.
- Coordinators and typed route enums own app navigation. Features request navigation through callbacks or coordinator APIs rather than mutating unrelated flows.
- Keep app-level auth/main flow switching in the existing coordinator structure.
- Use accessible labels, Dynamic Type-friendly layouts, and no fixed widths that clip localized text.

## Scope Guardrails

MVP work includes authentication, onboarding preferences, zones, natural-language and manual goal creation, AI task breakdown, local scheduling, conflict nudges, recurring tasks, summaries, reminders, offline persistence, and cloud sync.

Do not implement these deferred families unless a ticket explicitly brings them into scope:

- Social/connected features, marketplace, challenges, or shared goals.
- Personal/public templates or the RAG re-templating pipeline.
- GitHub, Strava, or photo-based task verification.
- Self-hosted/on-device AI, writable calendar integration, widgets, Live Activities, voice input, or advanced insights.

## Verification

Run the narrowest useful checks for the changed layer.

```bash
swift test --package-path Modules/Domain
swift test --package-path Modules/Data
swift test --package-path Modules/Network
xcodebuild -workspace Awan.xcworkspace -scheme Awan -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Use an installed simulator when the named device is unavailable. Add focused tests for use cases, conflict-engine vectors, mapping, repository reconciliation, sync behavior, and view-model state transitions.

If a check cannot run, report the exact command and failure reason. Do not claim unrun verification.

## Documentation Maintenance

- Update `Design.md` when product scope, module responsibilities, data flow, or app flow changes.
- Update `Layers/Agent.md` when a layer boundary or dependency direction changes.
- Update `Modules/UI_MODULE_STRUCTURE.md` when the standard feature folder/naming pattern changes.
- Update `AGENTS.md` and `.agents/rules/project-rules.md` when agent workflow, Git conventions, or verification expectations change.

When in doubt, choose the smallest change that preserves dependency direction and the product contract.
