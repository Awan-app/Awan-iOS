---
name: portfolio-readme
description: Generate a resume-grade README.md that showcases a project's architecture, tech stack, engineering decisions, features, and contributors for GitHub portfolio or resume use. Use when the user asks for /portfolio-readme, "$portfolio-readme", "portfolio README", "resume README", "showcase README", "write a README to highlight this project", or similar requests to present a repository professionally.
---

# Portfolio README Generator

## Goal

Generate a polished, recruiter-facing `README.md` for the current project.

The README should sell the project clearly and concisely by showing:

- what the project does
- who it is for
- its real architecture and engineering patterns
- its actual technology stack and why each technology is used
- its module/folder organization
- notable user-facing and engineering features
- contributors, when the repository has more than one human contributor

Do not invent technologies, architecture patterns, versions, features, contributors, links, screenshots, or claims.

Any additional text supplied with the skill invocation may specify:

- a target directory
- sections to emphasize
- sections to omit
- engineering qualities to highlight
- special context such as "stress offline support" or "focus on modular architecture"

Default target: the current repository root.

---

# 1. Understand the Repository

Before writing the README, inspect the repository.

Discover facts from the codebase instead of guessing.

## 1.1 Read project guidance first

Check for repository guidance and existing documentation when available:

- `AGENTS.md`
- `AGENTS.override.md`
- `CLAUDE.md`
- `README.md`
- `README.old.md`
- `CONTRIBUTING.md`
- `docs/`
- architecture documents
- project specifications

Treat `AGENTS.md` and applicable nested guidance as repository instructions.

Reuse useful project terminology and documented architectural decisions, but verify important claims against the actual repository when possible.

## 1.2 Inspect build and dependency files

Read the real build/configuration manifests relevant to the project, for example:

- `Package.swift`
- `.xcodeproj` / `.xcworkspace` project structure when useful
- `build.gradle`
- `build.gradle.kts`
- `settings.gradle`
- `settings.gradle.kts`
- `pubspec.yaml`
- `package.json`
- `Package.resolved`
- `Podfile`
- `pom.xml`
- `Cargo.toml`
- `go.mod`
- dependency lock files
- CI configuration
- lint configuration

Use these files to determine real:

- languages
- frameworks
- libraries
- package managers
- tooling
- supported platform information
- dependency injection tools
- networking libraries
- persistence solutions
- testing tools
- CI/CD tools

Only mention versions when they are clearly supported by repository evidence and are useful in the README.

## 1.3 Inspect the source layout

Inspect the directory/module tree to roughly 2-3 meaningful levels.

Determine:

- feature modules
- shared/core/common modules
- presentation layer
- domain layer
- data layer
- dependency direction
- navigation/coordinator structure
- dependency injection structure
- networking layer
- persistence layer
- test organization

Do not classify a folder as a specific architectural layer unless the code or project documentation supports that classification.

## 1.4 Inspect representative implementation files

Read the application entry point and a small set of representative files from important modules.

Use them to confirm patterns such as:

- Clean Architecture
- MVVM
- MVI
- Redux-style state management
- Coordinator
- Repository pattern
- Use Cases / Interactors
- Dependency Injection
- modular architecture
- protocol-oriented abstractions
- unidirectional data flow
- reactive streams
- structured concurrency

Do not infer an architecture merely from folder names.

## 1.5 Identify meaningful features

Look for actual user-facing and engineering features in:

- feature modules
- routes/navigation
- use cases
- API clients
- persistence code
- background work
- authentication
- notification systems
- synchronization
- offline handling
- AI integrations
- tests
- accessibility support
- localization
- CI/CD

Prefer features that demonstrate engineering ability or product value.

Avoid turning implementation details into fake product features.

---

# 2. Repository Exploration Strategy

For a small or medium repository, inspect the repository directly.

For a large repository where a single exploration pass would create excessive context or repeated work, use parallel subagents for independent, read-heavy exploration.

Good delegation boundaries include:

- architecture and module boundaries
- dependencies and tooling
- feature discovery
- persistence/networking
- tests and CI
- contributor/history analysis

Prefer read-heavy `explorer` subagents when available.

Do not use parallel agents merely because they exist.

When using subagents:

1. Give each agent a narrow, non-overlapping scope.
2. Ask each agent to return concise findings with file evidence.
3. Ask for:
   - technologies used
   - architecture role
   - notable features
   - relevant file paths
4. Wait for the requested agents to finish.
5. Merge and verify their findings before writing the README.

Avoid parallel write-heavy work on the same `README.md`.

The main agent owns the final README.

---

# 3. Evidence Rules

Every important claim in the README must be supported by repository evidence.

## Allowed

You may confidently describe something when supported by:

- source code
- project configuration
- dependency manifests
- tests
- repository documentation
- git history
- CI configuration

## Not allowed

Do not invent or assume:

- technologies
- framework versions
- architecture patterns
- performance claims
- security claims
- offline capabilities
- AI capabilities
- test coverage percentages
- deployment infrastructure
- contributors
- GitHub usernames
- screenshots
- demo links
- App Store / Play Store links
- production usage
- user counts

If evidence is ambiguous, either omit the claim or phrase it conservatively.

---

# 4. Contributors

Determine contributors from the repository's git history when git metadata is available.

Start with:

```bash
git shortlog -sne HEAD
```

This gives author names, emails, and approximate commit counts.

Collapse duplicate identities that clearly represent the same human using different emails or author strings.

Ignore obvious bots such as:

- `dependabot`
- `dependabot[bot]`
- `github-actions`
- `github-actions[bot]`
- automated release bots

## 4.1 Resolve GitHub profiles

If the repository has a GitHub remote and GitHub CLI access is available, inspect the remote:

```bash
git remote -v
```

Then, when useful, query contributors:

```bash
gh api "repos/{owner}/{repo}/contributors" --paginate --jq '.[].login'
```

Resolve a GitHub username only when there is reasonable evidence linking it to the git author.

Do not guess usernames.

If a GitHub profile cannot be confidently resolved, use the contributor's name without a profile link.

## 4.2 Team section rule

Include a `Team`, `Contributors`, or `Credits` section only when there is more than one distinct human contributor.

For linked contributors, prefer:

```md
- [Name](https://github.com/username)
```

For unresolved contributors:

```md
- Name
```

Do not expose contributor email addresses in the generated README unless the user explicitly asks for them.

---

# 5. Existing README Safety

Before replacing `README.md`, inspect the existing file if one exists.

If the existing README contains meaningful project content and the user did not explicitly ask to discard or overwrite it:

1. preserve it as `README.old.md`
2. do not overwrite an existing `README.old.md` blindly
3. if `README.old.md` already exists, choose a safe alternative such as:
   - `README.backup.md`
   - `README.old.1.md`

If the existing README is empty, placeholder-only, or clearly generated boilerplate, a backup is optional.

Never delete meaningful existing documentation without preserving it unless the user explicitly requests that.

---

# 6. Generate README.md

Adapt the structure to the actual project.

Do not force sections that do not make sense.

The preferred order is:

## 6.1 Title and project pitch

Start with:

```md
# Project Name
```

Follow with one concise paragraph explaining:

- what the project is
- who it helps or what problem it solves
- the strongest verified engineering qualities

Keep the pitch resume-friendly.

Avoid generic claims like:

- "cutting-edge"
- "revolutionary"
- "highly scalable"
- "enterprise-grade"

unless the repository provides real evidence for them.

## 6.2 Demo

Include a `Demo` section only if the repository or user provides real:

- screenshots
- demo GIFs
- demo videos
- YouTube links
- hosted demos

For a YouTube video with a known thumbnail, a clickable thumbnail may be used:

```md
[![Demo](thumbnail-url)](video-url)
```

Do not fabricate media or links.

If no demo evidence exists, omit this section.

## 6.3 Architecture

Explain the real architecture concisely.

Prefer either:

```md
## Architecture

| Layer / Pattern | Responsibility |
|---|---|
| Presentation | ... |
| Domain | ... |
| Data | ... |
```

or a tight bullet list when a table would be artificial.

Highlight meaningful concepts such as:

- dependency direction
- module boundaries
- feature isolation
- state management
- coordinators/navigation
- use cases
- repositories
- dependency injection

Only describe patterns that were verified.

## 6.4 Tech Stack

Use:

```md
## Tech Stack

| Technology | Description |
|---|---|
| SwiftUI | Declarative UI framework used for ... |
```

Each row should explain why the technology exists in this project, not merely define the technology.

Group technologies by concern when the table becomes long, for example:

- UI
- Architecture
- Networking
- Persistence
- Dependency Injection
- Concurrency
- Testing
- Tooling

Only add a logo column if the user explicitly requests logos.

## 6.5 Folder / Module Structure

Include a concise tree representing important architecture boundaries.

Example format:

```plaintext
Project/
├── App/                 # Application entry point and composition
├── Features/            # Feature modules
├── Domain/              # Business rules and use cases
├── Data/                # Repository/data-source implementations
└── Tests/               # Automated tests
```

This example is formatting guidance only.

The actual generated tree must match the repository.

Do not dump the entire repository.

Prefer a 2-3 level tree showing architecture rather than every file.

## 6.6 Key Features

Add a concise bullet list combining meaningful:

- user-facing capabilities
- engineering capabilities

Examples of engineering features worth mentioning when verified:

- modular feature boundaries
- offline persistence
- synchronization
- dependency injection
- structured concurrency
- push/local notifications
- authentication
- API integration
- accessibility
- localization
- automated tests
- CI/CD

Do not overstate unfinished or partially implemented features.

If something is clearly work-in-progress, label it appropriately or omit it.

## 6.7 Team / Contributors

Include only when the repository has more than one distinct human contributor.

Use the contributor rules from Section 4.

---

# 7. Writing Style

The README is a portfolio/resume artifact.

Use a confident, concise, technical style.

## Do

- use the repository's real domain vocabulary
- explain architecture clearly
- emphasize engineering decisions that can be verified
- keep paragraphs short
- make tables easy to scan
- highlight meaningful technologies
- write for recruiters and engineers
- prefer concrete statements over marketing language

## Do not

- write filler essays
- say "in this README"
- say "in this document we will"
- repeat the same information across sections
- add unnecessary badges
- generate fake metrics
- invent project history
- invent screenshots
- invent links
- claim something is "production-ready" without evidence
- list every transitive dependency
- expose secrets, tokens, credentials, private URLs, or contributor emails

Escape Markdown pipes inside table cells when necessary.

---

# 8. Validation Before Writing

Before creating the final file, verify:

- project name is correct
- project purpose is supported
- architecture claims have evidence
- technologies listed are actually used
- important dependencies are not omitted
- module tree matches the repository
- features are implemented or clearly supported
- contributor identities are not duplicated
- bots are excluded
- Team section follows the contributor-count rule
- demo links/media really exist
- no secrets or credentials are included
- no unsupported marketing claims remain

If practical, inspect the final Markdown after writing to catch:

- malformed tables
- broken code fences
- duplicate headings
- placeholder text
- incorrect relative paths

---

# 9. Deliver

Write the final result to:

```text
README.md
```

at the selected repository root.

After writing, report briefly:

- README path
- sections included
- architecture detected
- key technologies detected
- number of distinct human contributors
- whether a Team/Contributors section was added
- whether an existing README was backed up and where

Do not dump the entire README into the chat unless the user asks to see it.

The primary deliverable is the repository's `README.md`.
