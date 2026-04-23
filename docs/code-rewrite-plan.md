# Code Rewrite Plan

## Purpose

This document outlines a clean rewrite strategy for `yusr_app` with the goal of improving maintainability, performance, and clarity without changing the product’s core behavior.

The highest-priority problems this rewrite should solve are:

- [ ] slow startup and delayed rendering
- [ ] unnecessary loading states when cached data already exists
- [ ] heavy disk or sync work on the critical UI path
- [ ] mixed responsibilities across data, domain, and presentation layers
- [ ] inconsistent loading, caching, and state patterns across features

---

## 1. Rewrite goals

### Primary goals
- [ ] Make the app feel fast immediately after launch.
- [ ] Render important screens from cache first, then enrich them in the background.
- [ ] Separate business logic from UI logic more clearly.
- [ ] Standardize feature structure and naming.
- [ ] Reduce repeated code in repositories, cubits, and screens.
- [ ] Add test coverage around critical startup and Quran flows.

### Secondary goals
- [ ] Improve logging and failure visibility.
- [ ] Make offline behavior more predictable.
- [ ] Keep the app usable when background sync or remote services fail.
- [ ] Improve developer onboarding through cleaner code and documentation.

---

## 2. Current problems to fix

### Startup and boot flow
- [ ] The app does a lot of work during startup.
- [ ] Some useful data is already available in cache, but the app still waits for extra work before showing the screen.
- [ ] Deferred bootstrap work is correct in principle, but some preloading still blocks too much.

### Quran screen performance
- [ ] The surah list should appear quickly.
- [ ] Offline availability and page-image scanning are too expensive to block the first render.
- [ ] The Quran feature currently mixes:
  - [ ] catalog loading
  - [ ] local file scanning
  - [ ] offline availability calculation
  - [ ] sync progress updates
  - [ ] UI state transitions

### State and UI coupling
- [ ] Several screens still depend on full loading states instead of partial rendering.
- [ ] Some cubits reload data even when cached data is already in memory.
- [ ] UI widgets sometimes decide too much about data loading behavior.

### Repository complexity
- [ ] Repositories currently do too many jobs:
  - [ ] load from disk
  - [ ] load from remote
  - [ ] cache data
  - [ ] build indexes
  - [ ] compute derived data
- [ ] That makes them harder to test and change safely.

---

## 3. Architecture principles for the rewrite

### Principle 1 — Cache first, enrich later
If the app has cached data, show it immediately.
Background tasks should not prevent the UI from rendering.

### Principle 2 — One responsibility per layer
- `data`: load, parse, cache, persist
- `domain`: use cases and rules
- `presentation`: screen state and user interaction
- `core`: shared services, bootstrap, logging, sync

### Principle 3 — UI should not wait on expensive derived data
The first visible version of a screen should avoid:
- [ ] full directory scans
- [ ] large index generation
- [ ] network sync
- [ ] heavy computation

### Principle 4 — Explicit state
Use clear states such as:
- `initial`
- `ready`
- `loading`
- `empty`
- `error`
- `refreshing`
- `backgroundUpdating`

### Principle 5 — Background work must be non-blocking
Anything not required for first paint should be deferred.

---

## 4. Rewrite phases

## Phase 1 — Cleanup and baseline stabilization
### Tasks
- [ ] Audit all major feature folders.
- [ ] Identify duplicated patterns in:
  - [ ] repositories
  - [ ] cubits
  - [ ] UI loaders
  - [ ] local storage access
- [ ] Document current responsibilities and dependencies.
- [ ] Define the new folder and naming conventions to use across the app.

### Deliverables
- A clear feature architecture map.
- A list of “must keep,” “must rewrite,” and “can defer” modules.

---

## Phase 2 — Startup refactor
### Tasks
- [x] Minimize blocking work before the first frame.
- [x] Keep only essential bootstrap steps synchronous.
- [x] Move non-essential work to deferred initialization.
- [x] Preload small cached data sets early if they are needed for fast rendering.

### Expected outcome
- App shell shows faster.
- Main navigation is available sooner.
- Heavy services initialize without blocking first paint.

### Startup tasks to review
- [x] shared preferences
- [x] local storage bootstrap
- [x] Supabase initialization
- [x] settings initialization
- [x] lightweight catalog preload
- [x] deferred downloader setup
- [x] deferred notification setup
- [x] deferred sync orchestration

---

## Phase 3 — Quran feature rewrite
This is the most important user-facing performance area.

### Goals
- Show surah names immediately.
- Avoid blocking the list on page-image scanning.
- Keep badges and offline indicators as enrichment, not as blockers.
- Make refresh actions non-blocking when cache exists.

### Tasks
- [x] Split Quran loading into two parts:
  - [x] critical data for rendering the menu
  - [x] background enrichment for offline metadata
- [x] Make cached catalog access explicit.
- [x] Use a small and predictable initial state in the cubit.
- [x] Move local image-path scanning out of the critical UI path.
- [x] Cache derived indexes separately.
- [x] Show a partial UI if some metadata is still loading.
- [x] Keep full-screen loading only for real “no data available” cases.

### Expected outcome
- The surah menu appears immediately after opening Quran.
- Page availability badges fill in later.
- The screen feels responsive even on slower devices.

---

## Phase 4 — Repository simplification
### Tasks
- [ ] Break complex repository behavior into smaller units where needed.
- [ ] Separate:
  - [ ] raw data loading
  - [ ] cache access
  - [ ] derived index building
  - [ ] remote synchronization
- [x] Add explicit cache-peek methods only when needed.
- [x] Avoid repeated scans by storing computed results in memory.

### Example refactor direction
- `loadSurahs()` should fetch or return cached catalog data.
- `peekCachedSurahs()` should return memory state without disk I/O.
- `loadLocalPageImagePaths()` should be background-oriented.
- Derived maps such as page indexes should be built lazily or separately.

### Expected outcome
- Less work in the hot path.
- Better testability.
- Easier to reason about performance.

---

## Phase 5 — Presentation layer simplification
### Tasks
- [x] Ensure cubits initialize from cache when possible.
- [x] Avoid redundant `loadData()` calls when the state is already ready.
- [x] Use loading states only when necessary.
- [x] Make the UI resilient to partial data availability.
- [x] Reduce direct repository knowledge inside widgets.

### Screen patterns to adopt
- render cached content first
- load extra metadata afterward
- show retry cards for true failure states
- never block a screen that already has something useful to show

---

## Phase 6 — Shared core cleanup
### Tasks
- [ ] Review shared services in `core/`.
- [ ] Make bootstrap, logging, sync, and storage responsibilities explicit.
- [ ] Reduce hidden dependencies in service registration.
- [ ] Standardize error handling and recovery patterns.

### Important areas
- [ ] bootstrap service
- [ ] storage service
- [ ] notification service
- [ ] sync orchestrator
- [ ] logger
- [ ] localization

---

## Phase 7 — Testing and validation
### Unit tests
Add or strengthen tests for:
- [x] Quran cubit cache-first behavior
- [x] Quran repository cache access
- [x] startup bootstrap sequencing
- [x] settings load/sync fallback
- [x] content download state behavior

### Widget tests
Add tests for:
- [x] Quran screen renders surah menu from cached state
- [x] loading spinner only appears when there is truly no data
- [x] empty-state fallback when content is missing
- [x] refresh does not blank the screen

### Integration checks
- [x] startup does not block first paint
- [x] Quran opens quickly after app launch
- [x] app remains responsive during background sync

---

## 5. Recommended implementation sequence

### Step 1
- [x] Refactor startup to support cache-first rendering.

### Step 2
- [x] Refactor Quran flow so the surah list is visible immediately.

### Step 3
- [x] Move heavy derived-data work out of the UI path.

### Step 4
- [x] Clean up repository and cubit responsibilities.

### Step 5
- [x] Standardize loading and empty states across the app.

### Step 6
- [x] Add tests and verify the new behavior.

---

## 6. Design decisions to keep

The rewrite should preserve these good patterns already present in the app:

- feature-first folder organization
- dependency injection with `get_it`
- `flutter_bloc` for presentation state
- offline-first storage and cache usage
- modular feature areas like Quran, Adhkar, Prayer Times, Reminders, Settings, and Content Download
- deferred background work for notifications and sync
- RTL/LTR support driven by settings

---

## 7. Code quality standards for the rewrite

### Naming
- Use clear, descriptive names.
- Avoid abbreviations unless they are widely understood.
- Keep method names aligned with behavior.

### File size
- Keep files focused and readable.
- Split large files when they contain unrelated responsibilities.

### State shape
- Keep cubit state explicit and small.
- Avoid storing redundant derived values unless they are performance-critical.

### Error handling
- Log failures with context.
- Prefer graceful fallback over crashing or blocking.
- Keep UI usable when background services fail.

### Performance
- [x] Avoid repeated file scans.
- [x] Cache derived data.
- [x] Do not block the first render on non-essential work.

---

## 8. Risks and mitigation

### Risk: over-refactoring too much at once
**Mitigation:** rewrite in phases and verify each step.

### Risk: regressions in Quran behavior
**Mitigation:** add tests before and after changes, especially for cache-first loading.

### Risk: startup gets faster but data becomes stale
**Mitigation:** use background refresh and explicit cache invalidation.

### Risk: UI shows partial data inconsistently
**Mitigation:** define clear loading, ready, empty, and error states.

---

## 9. Success criteria

The rewrite is successful if:

- the app opens faster
- the Quran surah list is visible quickly
- loading indicators only appear when truly needed
- background work no longer blocks the UI
- repositories and cubits are easier to understand
- tests cover the important paths
- the codebase is cleaner and more maintainable

---

## 10. Next action items

- [ ] Confirm the rewrite scope.
- [x] Implement the startup and Quran cache-first refactor in small steps.
- [x] Add or update tests.
- [ ] Continue cleaning other features using the same pattern.
