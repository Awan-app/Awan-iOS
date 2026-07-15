# Awan Workspace Rule

Always apply the repository instructions and architecture references below before proposing or editing code:

- @/AGENTS.md
- @/Design.md
- @/Layers/Agent.md
- @/Modules/UI_MODULE_STRUCTURE.md

Key non-negotiables:

- This is a layer-first Clean Architecture repository using `Common`, `Network`, `Data`, `Domain`, and `Presentation` packages.
- Create ticket work from the latest `development` branch using `feature/AWAN-<number>-short-description` before editing.
- Put the same Jira key in the commit subject and pull request title.
- Feature pull requests target `development` and are ready for review unless explicitly requested as drafts.
- Keep the cloud AI Architect semantic-only; all calendar math belongs to the pure-Swift Local Conflict Engine.
- Keep the app offline-first with local persistence as the source of truth.
- Preserve package dependency direction and do not leak DTOs, persistence models, or concrete repositories across layers.
- Use Swift 6 concurrency, SwiftUI, Observation, constructor injection, and focused verification.
