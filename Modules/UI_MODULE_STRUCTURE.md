# Awan Layer-First UI Feature Structure

Use this guide when adding a SwiftUI feature to the existing Common, Network, Data, Domain, and Presentation packages.

## Target Shape

For a feature named `<Feature>`, add only the responsibilities it needs:

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
    `-- Views
        |-- Components
        |-- Sections
        `-- States
```

Do not create empty directories merely to match the diagram.

## Example Request Flow

```text
<Feature>View
-> <Feature>ViewModel
-> <Operation><Feature>UseCase
-> <Feature>Repository protocol
-> Default<Feature>Repository
-> local and/or remote data source
-> Network endpoint or local persistence
```

Response flow:

```text
ResponseDTO / persistence model
-> Data mapper
-> Domain entity
-> repository result/local observation
-> view-model state
-> SwiftUI rendering
```

## Public Surface

Keep declarations internal by default.

Usually public across packages:

- Domain entities/value objects used by Presentation or Data.
- Domain repository and use-case protocols.
- Presentation entry views/factories required by the app target.
- Network client interfaces required by Data.

Usually internal:

- Concrete repository implementations.
- Data sources, persistence models, DTO mappers.
- Concrete screen components.
- View-model construction details.

## View Model Pattern

Use Observation for new screens:

```swift
import Observation

@Observable
@MainActor
public final class <Feature>ViewModel {
    public private(set) var state: <Feature>State = .idle

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

Prefer an explicit state:

```swift
public enum <Feature>State: Equatable, Sendable {
    case idle
    case loading
    case content(<Entity>)
    case empty
    case failure(String)
}
```

For complex screens, multiple focused state values are acceptable when one large enum would create invalid or unreadable combinations.

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

Do not import SwiftUI, SwiftData, Core Data, URLSession, or Network into Domain.

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
        // Prefer local truth; refresh/reconcile through an explicit policy.
    }
}
```

Map explicitly:

```text
ResponseDTO -> Data model/persistence record -> Domain entity
```

Never return a DTO or SwiftData/Core Data model to Presentation.

## Composition

The app target creates concrete implementations and injects them down the graph:

```text
Network client
-> Data sources
-> repository implementation
-> Domain use case
-> Presentation view model/view
```

Use constructor injection. Do not resolve dependencies from inside SwiftUI views.

## Navigation

Use the existing coordinator pattern:

- Add a typed route to the owning flow.
- Add a destination mapping in that flow's root view/coordinator.
- Pass callbacks or coordinator operations into feature entry views.
- Keep Domain and Data navigation-agnostic.

## Feature Naming Example

For goal creation:

```text
Domain/Goals/Entities/Goal.swift
Domain/Goals/Repositories/GoalRepository.swift
Domain/Goals/UseCases/CreateGoalUseCase.swift
Network/Goals/DTOs/ParseGoalRequestDTO.swift
Network/Goals/DTOs/ParseGoalResponseDTO.swift
Data/Goals/DataSources/RemoteGoalDataSource.swift
Data/Goals/Mappers/GoalMapper.swift
Data/Goals/Repositories/DefaultGoalRepository.swift
Presentation/Goals/ViewModels/GoalCreationViewModel.swift
Presentation/Goals/Views/GoalCreationView.swift
Presentation/Goals/Views/GoalCreationState.swift
```

## Verification Checklist

1. The branch, commit, and PR title contain the Jira key.
2. Domain is platform-independent and deterministic.
3. Presentation has no concrete data/network imports.
4. DTOs and persistence types do not escape Data.
5. New public API is necessary and minimal.
6. Use cases, mappers, repositories, and view-model state transitions have focused tests.
7. The affected package tests or the Awan workspace build pass.
