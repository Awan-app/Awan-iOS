# Awan Layer Guide For Agents

This guide defines ownership and allowed dependencies for the layer-first modules. It contains technical conventions only; product behavior and domain algorithms belong in dedicated specifications.

## Standard Feature Placement

```text
Modules/Common/Sources/Common/<SharedArea>
Modules/Network/Sources/Network/<Feature>
Modules/Data/Sources/Data/<Feature>
Modules/Domain/Sources/Domain/<Feature>
Modules/Presentation/Sources/Presentation/<Feature>
```

Create folders only in the layers a feature actually needs.

## Domain

Purpose: business meaning, rules, and application operations.

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

- Entities and value objects.
- Repository protocols.
- Use cases and domain services.
- Business validation and domain errors.

Not allowed:

- SwiftUI, Combine presentation state, navigation routes, or view models.
- Persistence models or queries.
- URLSession, HTTP behavior, or DTOs.
- Concrete repository implementations.
- DI containers.

Conventions:

- Prefer immutable `Equatable`, `Sendable` value types.
- Keep use cases focused on one operation.
- Express important concepts with domain types instead of unrelated primitives.
- Return domain errors; Presentation maps them to user-facing text.
- Unit-test business rules directly in Domain.

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

- URLSession and HTTP client behavior.
- Endpoint paths, methods, headers, and encoding.
- Codable request/response DTOs.
- Transport errors, authentication mechanics, cancellation, and retry mechanics.

Not allowed:

- Business rules or use cases.
- SwiftUI, view models, or UI state.
- Persistence queries.
- Domain decision-making.

Conventions:

- Keep secrets out of source and logs.
- Expose typed transport APIs.
- Keep DTOs within the Network/Data boundary.
- Map transport failures before they cross into Domain-facing repository APIs.

## Data

Purpose: concrete repository behavior, persistence, mapping, and data coordination.

Typical folders:

```text
Data/<Feature>/
|-- DataSources
|-- Models
|-- Mappers
|-- Repositories
`-- Persistence
```

Allowed:

- Implement Domain repository protocols.
- Import Domain and Network.
- Define persistence models and queries.
- Call Network clients.
- Map DTOs and persistence records to Domain entities.
- Coordinate local and remote data sources according to approved requirements.

Not allowed:

- SwiftUI, view models, screen state, or navigation.
- Business rules that belong in entities, use cases, or domain services.
- Leaking DTOs or persistence models to Domain or Presentation.

Conventions:

- Keep mapping explicit and tested.
- Keep concurrency-sensitive data coordination behind an actor or another reviewed safe boundary.
- Repositories answer Domain contracts; they do not decide presentation behavior.

## Presentation

Purpose: user interaction, UI state, formatting, and navigation.

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
- Combine-based `ObservableObject` view models.
- `@Published` UI state.
- UI formatting and presentation-only transformations.
- Typed routes and coordinators.
- Calling injected Domain use cases.

Not allowed:

- The Observation framework or `@Observable`.
- Business logic, domain validation, or domain calculations in view models.
- Direct networking or persistence access.
- Constructing repositories, data sources, or network clients.
- DTO or persistence-model mapping.

Conventions:

- Mark view models `@MainActor`.
- Inject use cases through initializers.
- View models coordinate calls and publish UI state; use cases make business decisions.
- Keep views declarative.
- Model loading, content, empty, and failure states intentionally.
- Keep coordinators responsible for navigation paths and modal presentation.
- Keep UI accessible and localization-ready.

## Common

Purpose: stable shared primitives with multiple consumers.

Allowed:

- Shared coordinator contracts.
- Design-system tokens and reusable non-feature UI controls.
- Small stable utilities needed by multiple packages.

Not allowed:

- Feature-specific behavior or business rules.
- Helpers with only one consumer.
- DTOs, persistence models, or repositories.

Require at least two genuine consumers and a stable abstraction before moving code to Common.

## App Composition Root

Purpose: construct the dependency graph and configure application services.

Allowed:

- Create Network clients and Data repositories.
- Create use cases and inject them into Presentation.
- Configure persistence and other app-wide platform services.
- Install the root coordinator.

Not allowed:

- Business rules.
- DTO/domain mapping.
- Reusable screen implementation.

Use constructor injection. Do not add a service locator or DI framework without an explicit architecture decision.

## Placement Cheat Sheet

- Entity/value object: `Domain/<Feature>/Entities`.
- Business operation: `Domain/<Feature>/UseCases`.
- Repository contract: `Domain/<Feature>/Repositories`.
- REST DTO or endpoint: `Network/<Feature>`.
- Remote/local data source or mapper: `Data/<Feature>`.
- Repository implementation: `Data/<Feature>/Repositories`.
- Persistence model: `Data/<Feature>/Persistence`.
- Screen or view model: `Presentation/<Feature>`.
- Navigation destination: `Presentation/Navigation` or the feature navigation folder.
- Shared theme primitive: `Common/DesignSystem` after multiple consumers exist.

## Cross-Layer Review Checklist

1. Domain has no UI, persistence, or transport imports.
2. Presentation depends on abstractions rather than concrete Data types.
3. View models contain no business logic.
4. Network DTOs and persistence records stop at Data mappers.
5. App composition is the only place that knows all concrete implementations.
6. Public declarations are limited to necessary package boundaries.
7. Tests are written at the layer where the behavior belongs.
