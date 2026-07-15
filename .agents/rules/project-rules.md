# Awan Workspace Rule

Always apply the repository instructions and architecture references below before proposing or editing code:

- @/AGENTS.md
- @/Design.md
- @/Layers/Agent.md
- @/Modules/UI_MODULE_STRUCTURE.md

Key conventions:

- This is a layer-first Clean Architecture repository using `Common`, `Network`, `Data`, `Domain`, and `Presentation` packages.
- Create ticket work from the latest `development` branch using `feature/AWAN-<number>-short-description` before editing.
- Put the same Jira key in the commit subject and pull request title.
- Feature pull requests target `development` and are ready for review unless explicitly requested as drafts.
- Use SwiftUI with Combine-based `ObservableObject` and `@Published`; do not use the Observation framework or `@Observable`.
- View models coordinate use-case calls and UI state only. They must never contain business rules, domain validation, persistence policy, or networking logic.
- Preserve dependency direction and do not leak DTOs, persistence models, or concrete repositories across layers.
- Use constructor injection, Swift concurrency, minimal public APIs, and focused verification.
- Do not add product requirements, business behavior, or domain algorithms to agent configuration files. Read them from their dedicated specifications.
