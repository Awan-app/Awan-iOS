# Awan iOS Architecture Design

This document describes the repository's technical architecture and dependency rules. It intentionally excludes product requirements, business rules, and domain algorithms. Those belong in dedicated specifications and domain documentation.

## Architecture Style

The project uses layer-first Clean Architecture. Each layer is a Swift package under `Modules/`, and features are folders repeated inside the packages they require.

```text
Modules/
|-- Common
|-- Network
|-- Data
|-- Domain
`-- Presentation
```

This structure keeps dependency direction visible and avoids creating a separate package for every feature.

## Dependency Direction

```text
Awan app (composition root)
|-- Presentation --> Domain
|-- Data ---------> Domain
|   `-------------> Network
|-- Network
|-- Domain
`-- Common
```

Rules:

- Domain does not depend on Presentation, Data, Network, or Apple UI/persistence frameworks.
- Presentation depends on Domain abstractions and may use Common UI primitives.
- Data depends on Domain contracts and Network transport types.
- Network contains transport concerns only.
- Common contains stable shared primitives with multiple consumers.
- The app target constructs the concrete dependency graph.

## Common

Common contains stable code reused across packages.

Appropriate responsibilities:

- Shared UI tokens and genuinely reusable components.
- Coordinator contracts shared by presentation flows.
- Small utilities with multiple real consumers.
- Cross-package test helpers when justified.

Common must not contain feature-specific business logic, repositories, DTOs, or persistence models.

## Domain

Domain is the center of the architecture and owns business behavior.

Appropriate responsibilities:

- Entities and value objects.
- Repository protocols.
- Use cases.
- Domain services and validation.
- Domain errors and results.

Domain must remain independent of SwiftUI, Observation-based presentation state, persistence frameworks, networking frameworks, transport DTOs, and dependency-injection frameworks.

Business logic belongs here, not in views, view models, repositories, or network clients.

## Network

Network owns remote transport and wire formats.

Alamofire is the project's selected networking library. Implementation details are intentionally outside this guide.

Appropriate responsibilities:

- HTTP client behavior.
- Endpoint definitions.
- Request and response DTOs.
- Encoding and decoding.
- Authentication headers, transport errors, cancellation, and retry mechanics.

Network must not contain business rules, presentation state, persistence behavior, or Domain entities.

## Data

Data implements the Domain data-access contracts.

Appropriate responsibilities:

- Concrete repository implementations.
- Remote and local data sources.
- Persistence models and queries.
- DTO and persistence mapping.
- Data caching and coordination policies defined by an approved technical requirement.

Data must not contain SwiftUI views, presentation state, navigation, or business rules. Repositories coordinate data; use cases decide business behavior.

The production local store uses SwiftData and follows these boundaries:

- The app composition root creates one persistent `ModelContainer` and injects it into Data.
- Data owns all `@Model` persistence classes; they are not exposed to Domain or Presentation.
- Focused task, goal, session, zone, template, and override actors query the shared container; there is no combined scheduling store abstraction.
- Task, goal, session, and zone local-source protocols exchange Domain values. Template and override inputs remain Data-only because they are persistence configuration, not Domain entities.
- The zone repository resolves a requested local Gregorian date by checking its override first and then its Sunday-based weekday template. Only the resolved Domain zones cross into Domain.
- Presentation never receives a `ModelContext`, imports SwiftData, uses `@Query`, or reads persistence values directly. Local values must be loaded through Domain use cases and processed by the scheduling engine before Presentation renders them.
- Template aggregate writes reconcile their owned zones, and aggregate deletion explicitly removes those zones in the same context because ownership uses UUID fields rather than SwiftData relationships.
- Repository implementations depend on local data-source protocols rather than persistence-framework-specific implementations.
- Tests exercise the real SwiftData actors with isolated in-memory `ModelContainer` instances.
- Development previews can instead inject six focused in-memory local sources with linked mock data. This selection is made only in the app composition root; repositories and Presentation use the same abstractions in either mode.

## Presentation

Presentation owns UI rendering, UI state, user events, and navigation.

Use SwiftUI with Observation-based view models.

Appropriate responsibilities:

- SwiftUI views.
- `@MainActor` view models using `@Observable`.
- Observable stored presentation state, with `@State`, `@Bindable`, and `@Environment` used at SwiftUI ownership boundaries.
- Formatting and UI-only transformations.
- Coordinators and typed routes.
- Calling injected Domain use cases in response to user actions.

View models must not contain business logic. They may coordinate a use-case call, handle cancellation, and convert its output or error into UI state. Validation and decisions that change domain outcomes belong in Domain.

Presentation must not access Alamofire or other networking APIs, persistence frameworks, DTOs, concrete repositories, or data sources directly.

## App Composition Root

The executable target is the composition root. It:

- Creates Network clients and Data implementations.
- Creates Domain use cases.
- Injects dependencies into Presentation.
- Configures app-wide platform services.
- Hosts the root coordinator.

Use constructor injection. Do not resolve dependencies inside views or view models, and do not introduce a service locator or DI framework without an explicit architecture decision.

## Request And Response Flow

```text
User action
-> SwiftUI View
-> Observation ViewModel
-> Domain Use Case
-> Domain Repository Contract
-> Data Repository Implementation
-> Data Source / Network Client
```

```text
DTO or persistence model
-> Data mapper
-> Domain entity/result
-> Use Case
-> ViewModel presentation state
-> SwiftUI View
```

Each boundary uses types owned by the receiving layer. DTOs and persistence models stop in Data; presentation models stop in Presentation.

## MVI Presentation Flow

Complex screens use a unidirectional Model-View-Intent flow:

```text
SwiftUI View
-> Screen Action
-> Observation ViewModel
-> Focused Domain Use Case
-> Domain Result
-> Presentation Mapper
-> Screen State
-> SwiftUI View
```

- Views send actions through one view-model entry point and never invoke use cases directly.
- The observable screen state is the only mutable UI source of truth.
- UI-only actions reduce state synchronously; data queries and mutations invoke focused use cases.
- A feature may inject an immutable, explicitly typed use-case bundle to keep constructors readable. The bundle contains no lookup behavior and is not a service locator.
- Shared business orchestration belongs in Domain services so focused use cases do not duplicate rules.

## Navigation

Navigation is coordinator-owned:

- Typed route enums describe destinations.
- Coordinators own navigation paths and modal state.
- Feature views emit navigation intents through callbacks or coordinator APIs.
- Domain and Data have no knowledge of routes or navigation stacks.

## Technical Decision Rules

- Follow existing project patterns before adding new abstractions.
- Keep declarations internal unless another package requires them.
- Prefer constructor injection and explicit dependencies.
- Avoid singletons and global mutable state.
- Keep types focused on one responsibility.
- Record architecture changes in an ADR or the relevant ticket before changing dependency direction.
- Do not place product requirements or domain algorithms in agent configuration files.
