
I’ll structure this as a clean rewrite plan for the Flutter app, with the immediate focus on performance, startup flow, and feature modularity.

## Proposed document
`docs/code-rewrite-plan.md`

## Comprehensive rewrite plan

### 1. Define rewrite goals
- Reduce startup time and first-screen blocking.
- Eliminate unnecessary loading states when cached content exists.
- Separate “critical render path” from “background enrichment.”
- Make feature modules easier to understand and maintain.
- Improve testability and reduce coupling between layers.

### 2. Establish a cleaner architecture baseline
- Keep a strict flow for each feature:
  - `data` for repositories/services/models
  - `domain` for use cases and interfaces
  - `presentation` for cubits/pages/widgets
- Move any cross-feature shared logic into `core`.
- Avoid direct repository access from UI when a use case already exists.
- Standardize naming and file organization across all features.

### 3. Rewrite startup to be cache-first
- Make app bootstrap initialize only the minimum required services before first paint.
- Preload small, high-value data early:
  - settings
  - cached Quran catalog
  - essential storage state
- Push expensive tasks to deferred/background initialization:
  - page-image scanning
  - sync orchestration
  - notification syncing
  - catalog enrichment
- Add explicit “ready vs background syncing” separation in startup state.

### 4. Rewrite the Quran flow for instant menu display
- Render the surah list from cached catalog data immediately.
- Do not block the menu on:
  - page-image scans
  - offline availability calculation
  - startup sync
- Load extra metadata after the list is visible.
- Keep refresh actions non-blocking when data is already available.
- Use small placeholders for badges instead of full-screen loaders.

### 5. Simplify loading-state behavior
- Replace broad “loading” screens with targeted skeletons or partial UI states.
- Only use a full-screen loader when the screen truly has nothing to show.
- For cached content, show the UI first and enrich it afterward.
- Make error states actionable:
  - retry
  - open content download
  - fallback to cached data

### 6. Reduce heavy disk and sync work
- Avoid scanning large directories on the critical path.
- Cache derived data like:
  - page availability
  - page-to-surah maps
  - last-read lookups
- Compute expensive indexes lazily or in background.
- Make sync jobs idempotent and resumable.

### 7. Clean up state management
- Ensure cubits initialize from cached state where possible.
- Prevent redundant reloads when state is already loaded.
- Keep state objects small and explicit.
- Separate “content loaded” from “background enrichment in progress.”

### 8. Standardize UI composition
- Keep screens thin and delegate logic to cubits/use cases.
- Prefer reusable widgets for:
  - loading states
  - empty states
  - retry cards
  - content badges
- Make list screens render incrementally instead of waiting for everything.

### 9. Improve observability and performance tracking
- Add feature-scoped logging for slow operations.
- Measure:
  - bootstrap duration
  - Quran menu time-to-first-render
  - scan duration for downloaded assets
  - sync failures
- Keep logs actionable and consistent.

### 10. Add tests before and after the rewrite
- Startup tests:
  - cached bootstrap
  - deferred background work
- Quran tests:
  - cached surah render path
  - empty-content fallback
  - no full-screen spinner when data is cached
- Settings tests:
  - language persistence
  - remote sync fallback
- Repository tests:
  - catalog loading
  - cache reuse
  - offline availability calculation

### 11. Documentation and developer onboarding
- Rewrite the README to describe the real app.
- Add docs for:
  - startup flow
  - data flow
  - Quran content handling
  - deployment/setup
- Keep design decisions in docs, not just in code comments.

### 12. Migration strategy
- Rewrite in small steps, not all at once.
- Sequence:
  1. startup and bootstrap cleanup
  2. Quran list/render path cleanup
  3. heavy cache/index work
  4. state and UI simplification
  5. tests and documentation
- Keep changes reversible and verifiable after each step.

## Recommended first rewrite target
- [x] Start with the Quran flow and app bootstrap, because that is where the visible slowness is happening:
  - [x] preload the catalog early
  - [x] render from cache immediately
  - [x] move offline badge computation off the critical path
  - [x] keep the menu visible even while background work continues
