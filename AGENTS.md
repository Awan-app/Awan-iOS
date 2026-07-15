# Awan iOS Agent Instructions

This file defines repository workflow, architecture boundaries, and coding conventions for Codex, Antigravity CLI, and other coding agents that support `AGENTS.md`.

These instructions do not define product behavior or business rules. Use the relevant specification, ticket, or dedicated domain document for those decisions. Never infer or add product behavior from this file.

Read `Design.md` and `Modules/UI_MODULE_STRUCTURE.md` before architecture-level work.

## Before Editing

- Run `git status --short` and preserve unrelated user changes.
- Confirm the active branch and fetch the latest remote state.
- Inspect the relevant `Package.swift` and nearby code before choosing a pattern.
- Prefer `rg` and `rg --files` for repository search.
- Keep changes scoped to the active Jira ticket.
- Do not edit generated artifacts, `.build`, `.swiftpm`, `DerivedData`, `xcuserdata`, or secrets.
- Do not invent missing business requirements. Ask for the relevant specification when a ticket is insufficient.

For ticketed work, create the branch before modifying project files.

## Git, Jira, Commit, And PR Naming

Jira development linking depends on the issue key being present in Git activity.

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

## Architecture

The repository uses layer-first Clean Architecture with Swift Package Manager modules:

```text
Modules/
|-- Common
|-- Network
|-- Data
|-- Domain
`-- Presentation
```

Features are folders repeated inside the existing layer packages. Do not create a package per feature unless an architecture decision explicitly changes this structure.

Preferred dependency direction:

```text
Awan app composition root
|-- Presentation -> Domain + Common
|-- Data -> Domain + Network
|-- Network
|-- Domain
`-- Common
```

- `Domain` owns entities, value objects, repository contracts, use cases, and business rules.
- `Data` implements Domain repositories and owns data sources, persistence models, mapping, and data coordination.
- `Network` owns transport, endpoints, authentication headers, request/response DTOs, and decoding. Alamofire is the selected networking library.
- `Presentation` owns SwiftUI, `ObservableObject` view models, UI state, coordinators, and routes.
- `Common` contains stable utilities and reusable UI primitives shared by multiple consumers. It is not a dumping ground.
- The `Awan` app target is the composition root. Use constructor injection; do not add a DI framework without an explicit decision.

## View And ViewModel Rules

Use SwiftUI with Combine-based `ObservableObject`. Do not use the Observation framework or `@Observable`.

- View models conform to `ObservableObject`, are marked `@MainActor`, and expose mutable UI state using `@Published`.
- Views remain declarative and render view-model state.
- View models translate user actions into use-case calls and map results into presentation state.
- View models must not contain business logic, validation rules, domain calculations, persistence decisions, or networking logic.
- Business decisions belong in Domain use cases, entities, value objects, or domain services.
- Data access goes through Domain repository abstractions.
- Views and view models must not construct repositories, data sources, or network clients.
- Use explicit loading, content, empty, and failure states where appropriate.
- Coordinators and typed routes own navigation. Domain and Data remain navigation-agnostic.

## Swift And Concurrency Conventions

- The supported development toolchain is Xcode 16 with the repository's configured Swift language mode.
- Honor strict concurrency diagnostics where enabled.
- Prefer immutable `struct` models and `Sendable` values across async boundaries.
- Prefer `async`/`await`; handle cancellation and errors explicitly.
- Keep UI state mutations on `@MainActor`.
- Avoid force unwraps and `try!` except for a documented programmer invariant.
- Avoid global mutable state and new singletons.
- Keep APIs internal by default. Use `public` only for a real package boundary.
- Use protocols at architectural boundaries, not for every concrete type.
- Prefer small, focused types and methods with one responsibility.
- Follow the existing code style before introducing a new pattern.

## Naming Conventions

- Feature folders use domain nouns: `<Feature>`.
- Domain entity: noun, for example `<Entity>`.
- Domain error: `<Feature>Error`, stored in `Domain/<Feature>/Errors` when typed domain failures are needed.
- Use case: verb plus noun plus `UseCase`, for example `Fetch<Feature>UseCase`.
- Repository contract: `<Feature>Repository`.
- Repository implementation: `Default<Feature>Repository` unless a more specific name is clearer.
- Data source: `<Source><Feature>DataSource`, such as `Remote<Feature>DataSource`.
- Transport models: `<Operation><Feature>RequestDTO` and `<Operation><Feature>ResponseDTO`.
- Persistence models: `<Feature>Record` or a name matching the selected persistence framework's convention.
- Mapper: explicit `toDomain()` or an initializer defined in Data.
- View: `<Screen>View`.
- View model: `<Screen>ViewModel`.
- UI state: `<Screen>State`.
- Coordinator: `<Flow>Coordinator`.
- Route: `<Flow>Route`.
- Test file: `<TypeName>Tests.swift`.

## Dependency And Data Boundaries

- Domain imports no UI, persistence, or transport framework.
- Presentation depends on Domain abstractions, never concrete Data implementations.
- Network DTOs and persistence models never escape into Domain or Presentation.
- Mapping belongs in Data.
- Network does not make business decisions.
- Data does not own presentation state.
- Common must not contain feature-specific behavior.
- The app composition root is the only place that wires concrete implementations together.

## Testing And Verification

- Test Domain rules and use cases without UI or infrastructure dependencies.
- Test Data mappers, repository behavior, and data-source coordination independently.
- Test view models by mocking use cases and asserting published UI-state transitions.
- Do not test business rules through view-model tests; test them at the Domain boundary.
- Add focused tests for new behavior and regressions.
- Run the narrowest useful package tests and the workspace build when integration risk warrants it.

```bash
swift test --package-path Modules/Domain
swift test --package-path Modules/Data
swift test --package-path Modules/Network
xcodebuild -workspace Awan.xcworkspace -scheme Awan -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Use an installed simulator if the named device is unavailable. If a check cannot run, report the command and exact failure reason. Never claim unrun verification.

## Documentation Maintenance

- Update `Design.md` when dependency direction or project-wide technical patterns change.
- Update `Design.md` when layer ownership changes.
- Update `Modules/UI_MODULE_STRUCTURE.md` when the feature folder pattern or Presentation conventions change.
- Update `AGENTS.md` and `.agents/rules/project-rules.md` when workflow or coding conventions change.
- Keep product requirements and domain algorithms in their dedicated documents, not in agent configuration files.

When in doubt, make the smallest change that preserves layer boundaries and existing conventions.
