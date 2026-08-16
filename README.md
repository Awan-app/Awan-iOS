# Awan iOS

Awan is a bilingual day-planning app for iOS that turns goals and tasks into practical schedules. It combines AI-assisted planning, a dependency-aware scheduling engine, reusable daily-zone templates, and gamified progress in a modular SwiftUI codebase built with layer-first Clean Architecture.

## Highlights

- Build a daily plan from tasks, goals, daily zones, availability, and task dependencies.
- Break goals into tasks, review proposed sessions, and adjust the schedule before confirming it.
- Capture tasks manually, by voice, or from a photo or camera image.
- Track sessions, deadlines, points, streaks, inventory, and marketplace rewards.
- Use the app in English or Arabic with automatic right-to-left layout and light/dark appearance preferences.
- Keep scheduling, profile, category, and gamification state in a SwiftData-backed local cache synchronized through repository abstractions.

## Architecture

Awan uses layer-first Clean Architecture: features repeat inside shared layer packages instead of becoming a package per feature. The app target is the composition root, where Swinject assemblies connect concrete infrastructure to Domain contracts and inject use cases, view models, factories, and coordinators.

| Layer / Pattern | Responsibility |
|---|---|
| **Awan app** | Creates the persistent `ModelContainer`, configures platform services, assembles dependencies, and launches the root presentation flow. |
| **Presentation** | SwiftUI screens, `@Observable` and `@MainActor` view models, screen state, presentation mapping, typed routes, and coordinators. Complex screens use a unidirectional Model-View-Intent flow. |
| **Domain** | UI- and infrastructure-independent entities, value objects, business rules, scheduling services, repository contracts, typed errors, and focused use cases. |
| **Data** | Repository implementations, remote and local data sources, DTO/persistence mapping, cache coordination, and SwiftData actors. |
| **Network** | Alamofire-based transport, endpoint contracts, encoding/decoding, multipart uploads, authentication interception, and token refresh. |
| **Common** | Shared design-system tokens and components, localization, media abstractions, coordinator contracts, and reusable utilities. |

```text
User action
  -> SwiftUI View
  -> Observable ViewModel / Screen Action
  -> Domain Use Case
  -> Repository Contract
  -> Data Repository
  -> Local Data Source or Network Client
```

Transport DTOs and SwiftData models stop at the Data boundary. Presentation renders Domain results through observable UI state and never accesses persistence or networking directly.

## Tech Stack

| Concern | Technology | Role in Awan |
|---|---|---|
| Language and UI | Swift, SwiftUI | Builds the iOS interface and app composition layer. |
| State management | Observation, Combine | Drives main-actor view-model state and reactive streams from cached repository data. |
| Concurrency | Swift concurrency | Implements asynchronous use cases, networking, persistence coordination, and parallel data loading with `async`/`await`. |
| Persistence | SwiftData | Stores goals, tasks, sessions, zones, templates, overrides, profile data, categories, and gamification inventory through actor-backed data sources. |
| Networking | Alamofire | Provides typed HTTP requests, validation, multipart uploads, authenticated requests, and refresh handling. |
| Session storage | SimpleKeychain | Persists authentication session material and the per-install device identifier. |
| Authentication | Firebase Authentication, Google Sign-In | Exchanges Google credentials and manages the backend authentication flow alongside email OTP sign-in. |
| Dependency injection | Swinject | Organizes Data, Domain, and Presentation registrations at the app composition root. |
| Media and motion | Kingfisher, Lottie | Loads authenticated remote images and renders mascot, streak, and reward animations. |
| Apple frameworks | Speech, AVFAudio, PhotosUI, UserNotifications | Supports voice input, camera/photo task extraction, and local session/deadline reminders. |
| Tooling | Swift Package Manager, XCTest, SwiftLint, GitHub Actions | Manages modular dependencies, layer-focused test targets, linting, and configured simulator build checks. |

The application targets **iOS 18** and the repository's supported development toolchain is **Xcode 16**.

## Module Structure

```text
Awan-iOS/
├── Awan/                         # App entry point and composition root
│   └── DependencyInjection/      # Swinject assemblies for Data, Domain, and UI
├── Modules/
│   ├── Common/                   # Design system, localization, shared utilities
│   ├── Domain/                   # Entities, services, contracts, and use cases
│   ├── Network/                  # HTTP client, authentication, and transport types
│   ├── Data/                     # Repositories, data sources, mappers, SwiftData
│   └── Presentation/             # Feature UI, observable state, routes, coordinators
├── AwanTests/                    # Application unit tests
├── AwanUITests/                  # Application UI tests
└── .github/workflows/            # Lint and simulator-build workflow
```

Feature folders span only the layers they need. Scheduling, templates, gamification, onboarding, profile, authentication, and AI-assisted creation therefore retain clear boundaries without duplicating package infrastructure.

## Key Features

- **Adaptive daily planning:** day and week navigation, session timelines, drag-based rescheduling with time snapping, completion tracking, and schedule updates.
- **Dependency-aware scheduling:** Domain services order task dependencies, detect missing or cyclic relationships, find category-zone availability, exclude occupied time, and propose resolutions when time is insufficient.
- **Goal planning assistant:** conversational goal decomposition, proposal confirmation, schedule generation, session review and editing, and explicit handling for unresolved tasks.
- **Flexible task capture:** manual and scheduled tasks, text-based proposals, speech transcription, and image-to-task extraction from the photo library or camera.
- **Task and goal management:** searchable inbox, task details, goal assignment, dependency editing, session editing, deadlines, completion, reopening, and deletion flows.
- **Daily zones and templates:** reusable weekday templates, date-specific overrides, categorized time zones, overlap validation, reordering, and bulk persistence.
- **Gamified progress:** points, streak celebrations, activity history, a daily wheel, storefront browsing, purchases, inventory, and item equip/unequip flows.
- **Authentication and onboarding:** email OTP and Google Sign-In flows, profile setup, wake/sleep preferences, scheduling preferences, zone setup, and notification consent.
- **Localized reminders:** session alerts before and at start time plus goal-deadline reminders, with localized English and Arabic content.
- **Profile personalization:** profile photo and personal details, theme and language preferences, scheduling settings, equipped cosmetics, and secure logout with local-data cleanup.

## Quality and Verification

The repository contains XCTest targets across the architecture packages and the application. Existing suites exercise scheduling rules, dependency ordering, use cases, template resolution, endpoint contracts, DTO decoding, SwiftData data sources, repository coordination, and presentation view models.

The GitHub Actions workflow is configured to run strict SwiftLint checks before an unsigned iOS Simulator build, with Swift Package Manager dependency caching.

## Team

- [Eslam Elnady](https://github.com/EslamElnady0)
- [Andrew-Magdy-1](https://github.com/Andrew-Magdy-1)
- [MennaMohamed23](https://github.com/MennaMohamed23)
- [Ahmed Sayed](https://github.com/ahmedSayed321)
