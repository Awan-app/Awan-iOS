# Awan Layer Guide For Agents

This guide defines ownership and allowed dependencies for the layer-first modules in Awan.

## Standard Feature Placement

A feature spans the existing layer packages instead of creating a feature package:

```text
Modules/Common/Sources/Common/<SharedArea>
Modules/Network/Sources/Network/<Feature>
Modules/Data/Sources/Data/<Feature>
Modules/Domain/Sources/Domain/<Feature>
Modules/Presentation/Sources/Presentation/<Feature>
```

Only create folders in layers the feature actually needs.

## Domain

Purpose: business meaning and deterministic behavior.

Typical folders:

```text
Domain/<Feature>/
|-- Entities
|-- Repositories
|-- UseCases
|-- Errors
`-- Services
```

Allowed:

- Entities, value objects, and domain errors.
- Repository protocols.
- Use-case protocols and implementations.
- Validation and deterministic scheduling algorithms.
- Foundation value types when platform-neutral.

Not allowed:

- SwiftUI, Observation, navigation routes, or view state.
- SwiftData/Core Data managed models.
- URLSession, HTTP status handling, or DTOs.
- Concrete repository implementations.
- DI containers.

Rules:

- Keep the Local Conflict Engine pure Swift and independently testable.
- Prefer immutable `Equatable`, `Sendable` structs.
- Use meaningful domain types rather than primitive strings for zone, priority, recurrence, and sync-independent identifiers.
- Do not put display strings in Domain errors; map them in Presentation.

## Network

Purpose: HTTP transport and wire formats.

Typical folders:

```text
Network/<Feature>/
|-- Endpoints
|-- DTOs
|-- Requests
`-- Responses
```

Allowed:

- URLSession/HTTP client behavior.
- Endpoint paths, methods, headers, and encoding.
- Codable request/response DTOs.
- Transport errors, authentication refresh, cancellation, and retry policy.

Not allowed:

- Domain use cases or scheduling rules.
- SwiftUI and view state.
- Local database queries.
- Mapping policy that requires business decisions.

Rules:

- Keep secrets out of source and logs.
- Keep `/v1/parse`, `/v1/sync`, and `/v1/auth/*` behind typed endpoint APIs.
- Treat the AI task-breakdown response as a versioned wire contract.
- Do not expose DTOs outside Network/Data integration boundaries.

## Data

Purpose: concrete repository behavior, persistence, mapping, and synchronization.

Typical folders:

```text
Data/<Feature>/
|-- DataSources
|-- Models
|-- Mappers
|-- Repositories
|-- Persistence
`-- Sync
```

Allowed:

- Implement Domain repository protocols.
- Import Domain and Network.
- Define SwiftData/Core Data models.
- Read/write local storage.
- Call Network clients.
- Map DTOs and persistence records to Domain entities.
- Queue offline mutations and reconcile server state.

Not allowed:

- SwiftUI views, screen state, or navigation.
- Business rules that belong in a use case or conflict engine.
- Leaking DTOs or persistence models to Domain/Presentation.

Rules:

- Read UI-facing state from local persistence.
- Apply remote results to the local store, then let observation update the UI.
- Keep mapping explicit and tested.
- Hide Last-Write-Wins and sync-state details behind repositories.
- Use an actor or another reviewed concurrency-safe boundary for the sync queue.

## Presentation

Purpose: user interaction, UI state, and navigation.

Typical folders:

```text
Presentation/<Feature>/
|-- ViewModels
|-- Views
|   |-- Components
|   |-- Sections
|   `-- States
`-- Navigation
```

Allowed:

- SwiftUI views.
- `@Observable`, `@MainActor` view models.
- UI state and formatting.
- Typed routes and coordinators.
- User intents that invoke use cases.

Not allowed:

- Direct URLSession calls.
- SwiftData/Core Data fetch/save behavior in views.
- Constructing concrete repositories or data sources.
- JSON/DTO mapping.
- Core scheduling algorithms.

Rules:

- Inject Domain use cases through initializers.
- Keep views declarative.
- Model idle/loading/content/empty/failure states intentionally.
- Keep coordinators responsible for paths, sheets, and auth/main flow changes.
- Keep UI code accessible and localization-ready.

## Common

Purpose: stable shared primitives and reusable UI infrastructure.

Allowed:

- Coordinator contracts used across presentation flows.
- Design-system tokens and reusable non-feature UI controls.
- Stable utilities needed by multiple real consumers.

Not allowed:

- Feature-specific business logic.
- A generic home for helpers used once.
- Network DTOs or persistence models.
- Concrete repositories.

Rule of thumb: require at least two genuine consumers and a stable abstraction before moving code to Common.

## App Composition Root

Purpose: construct the dependency graph and configure application services.

Allowed:

- Create Network clients and Data repositories.
- Inject repository-backed use cases into Presentation.
- Configure SwiftData/Core Data containers.
- Register background tasks and notifications.
- Install the root coordinator into the SwiftUI environment.

Not allowed:

- Feature business rules.
- DTO/domain mapping.
- Reusable screen implementation.

Use constructor injection. Do not add a service locator or DI framework without an explicit architecture decision.

## Placement Cheat Sheet

- New entity/value object: `Domain/<Feature>/Entities`.
- New business operation: `Domain/<Feature>/UseCases`.
- New repository contract: `Domain/<Feature>/Repositories`.
- New REST DTO/endpoint: `Network/<Feature>`.
- New remote/local source or mapper: `Data/<Feature>`.
- New repository implementation: `Data/<Feature>/Repositories`.
- New SwiftData/Core Data model: `Data/<Feature>/Persistence`.
- New screen/view model: `Presentation/<Feature>`.
- New navigation destination: `Presentation/Navigation` or the feature's navigation folder.
- New reusable theme primitive: `Common/DesignSystem` only after it has multiple consumers.

## Cross-Layer Review Checklist

Before finishing a feature:

1. Domain has no UI, persistence, or transport imports.
2. Presentation depends on abstractions rather than concrete Data types.
3. Network DTOs and persistence records stop at Data mappers.
4. Local persistence remains the source of truth.
5. Scheduling behavior is deterministic and tested outside the UI.
6. App composition is the only place that knows concrete implementations.
7. Public declarations are limited to real package boundaries.
