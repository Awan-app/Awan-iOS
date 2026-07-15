# Awan Layer-First UI Feature Structure

Use this guide when adding a SwiftUI feature to the Common, Network, Data, Domain, and Presentation packages. This file defines structure and coding conventions only; it does not define product behavior.

## Target Shape

```text
Modules/
|-- Domain/Sources/Domain/<Feature>/
|   |-- Entities
|   |-- Repositories
|   `-- UseCases
|-- Network/Sources/Network/<Feature>/
|   |-- Endpoints
|   `-- DTOs
|-- Data/Sources/Data/<Feature>/
|   |-- DataSources
|   |-- Models
|   |-- Mappers
|   |-- Repositories
|   `-- Persistence
`-- Presentation/Sources/Presentation/<Feature>/
    |-- ViewModels
    |-- Views
    |   |-- Components
    |   |-- Sections
    |   `-- States
    `-- Navigation
```

Do not create empty directories merely to match the diagram.

## Dependency Flow

```text
<Feature>View
-> <Feature>ViewModel
-> <Operation><Feature>UseCase
-> <Feature>Repository protocol
-> Default<Feature>Repository
-> local or remote data source
```

```text
ResponseDTO / persistence model
-> Data mapper
-> Domain entity
-> Use Case result
-> ViewModel UI state
-> SwiftUI rendering
```

## Public Surface

Keep declarations internal by default.

Usually public across packages:

- Domain entities and value objects used by Data or Presentation.
- Domain repository and use-case protocols.
- Presentation entry views or factories required by the app target.
- Network client interfaces required by Data.

Usually internal:

- Concrete repository implementations.
- Data sources, persistence models, and DTO mappers.
- Screen components.
- View-model construction details.

## ViewModel Pattern

The project uses Combine-based `ObservableObject`. Do not use the Observation framework or `@Observable`.

```swift
import Combine

@MainActor
public final class <Feature>ViewModel: ObservableObject {
    @Published public private(set) var state: <Feature>State = .idle

    private let useCase: any <Operation><Feature>UseCase

    public init(useCase: any <Operation><Feature>UseCase) {
        self.useCase = useCase
    }

    public func load() async {
        state = .loading

        do {
            let value = try await useCase.execute()
            state = .content(value)
        } catch is CancellationError {
            return
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
}
```

```swift
public enum <Feature>State: Equatable, Sendable {
    case idle
    case loading
    case content(<Entity>)
    case empty
    case failure(String)
}
```

For complex screens, multiple focused published properties are acceptable when one state enum becomes unreadable.

### ViewModel Boundary

A view model may:

- Receive user events.
- Call an injected use case.
- Handle task cancellation.
- Convert Domain results and errors into UI state.
- Apply UI-only formatting.
- Ask a coordinator to navigate.

A view model must not:

- Implement business rules or domain validation.
- Perform domain calculations.
- Decide persistence or caching policy.
- Call URLSession or a persistence framework.
- Construct or access a concrete repository.
- Map transport DTOs or persistence records.

If code changes an application outcome based on a business rule, move it to a Domain use case, entity, value object, or domain service.

## Domain Boundary Pattern

```swift
public protocol <Feature>Repository: Sendable {
    func fetch() async throws -> <Entity>
}

public protocol <Operation><Feature>UseCase: Sendable {
    func execute() async throws -> <Entity>
}

public struct Default<Operation><Feature>UseCase: <Operation><Feature>UseCase {
    private let repository: any <Feature>Repository

    public init(repository: any <Feature>Repository) {
        self.repository = repository
    }

    public func execute() async throws -> <Entity> {
        try await repository.fetch()
    }
}
```

Domain must not import SwiftUI, Combine, persistence frameworks, URLSession, or Network.

## Data Boundary Pattern

```swift
public struct Default<Feature>Repository: <Feature>Repository {
    private let localDataSource: any Local<Feature>DataSource
    private let remoteDataSource: any Remote<Feature>DataSource

    public init(
        localDataSource: any Local<Feature>DataSource,
        remoteDataSource: any Remote<Feature>DataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    public func fetch() async throws -> <Entity> {
        // Coordinate data sources according to the approved requirement.
    }
}
```

Map explicitly:

```text
ResponseDTO -> Data model or persistence record -> Domain entity
```

Never return a DTO or persistence model to Presentation.

## Composition

The app target creates concrete implementations and injects them down the graph:

```text
Network client
-> Data sources
-> Repository implementation
-> Domain use case
-> Presentation view model and view
```

Use constructor injection. Do not resolve dependencies from inside SwiftUI views or view models.

## Navigation

- Add a typed route to the owning flow.
- Add destination mapping in that flow's coordinator or root view.
- Pass callbacks or coordinator operations into feature entry views.
- Keep Domain and Data navigation-agnostic.

## Naming Example

```text
Domain/<Feature>/Entities/<Entity>.swift
Domain/<Feature>/Repositories/<Feature>Repository.swift
Domain/<Feature>/UseCases/Fetch<Feature>UseCase.swift
Network/<Feature>/DTOs/Fetch<Feature>RequestDTO.swift
Network/<Feature>/DTOs/Fetch<Feature>ResponseDTO.swift
Data/<Feature>/DataSources/Remote<Feature>DataSource.swift
Data/<Feature>/Mappers/<Feature>Mapper.swift
Data/<Feature>/Repositories/Default<Feature>Repository.swift
Presentation/<Feature>/ViewModels/<Feature>ViewModel.swift
Presentation/<Feature>/Views/<Feature>View.swift
Presentation/<Feature>/Views/<Feature>State.swift
```

## Verification Checklist

1. Domain is independent of UI and infrastructure frameworks.
2. Presentation has no concrete Data or Network imports.
3. View models use `ObservableObject` and `@Published`, not Observation.
4. View models contain no business logic.
5. DTOs and persistence types do not escape Data.
6. Public API is necessary and minimal.
7. Tests target the layer that owns the behavior.
8. Affected package tests or the workspace build pass.
