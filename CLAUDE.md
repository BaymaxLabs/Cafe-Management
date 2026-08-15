# Cafe Management

Flutter cafe management app ("Brew") built spec-first with Claude Code.

## Source of Truth

- **Figma** (`https://www.figma.com/make/1MrydbK8RMEHYHWHzmq8FL/`) is the source of truth for UI/UX.
- `docs/architecture.md` is the source of truth for folder structure, naming, and patterns.
- Existing code is the source of truth for established project conventions.
- When Figma and existing implementation differ, follow Figma for visual design unless there is a documented technical constraint.

## Architecture

- Feature-first folder structure: `lib/features/<feature>/models|services|state|screens|widgets/`.
- Shared cross-feature code lives in `lib/widgets/` or `lib/core/`.
- No cross-feature imports — if two features need the same thing, it belongs in `lib/widgets/` or `lib/core/`.
- Services have no Flutter deps — plain Dart in, models out, exceptions on error.
- State (ChangeNotifiers) owns business logic. Screens call state; state calls services. Screens never call services directly.
- UI must not directly access APIs, databases, or persistence.
- See `docs/architecture.md` for the full folder tree, design tokens, and feature plans.

## Branching

- Always create a new branch before starting any task.
- Branch naming: `feat/`, `fix/`, `chore/`, `test/`, `refactor/` + short description.
- Never commit directly to `main`.

## Testing

- Tests live in `test/` mirroring the `lib/` feature-first structure.
- Write specs before implementation (spec-first / TDD).
- Skipped stubs exist for unbuilt classes — restore and fill them in when building the corresponding class.
- Shared test helpers live in `test/helpers/test_helpers.dart`.
- Run after every change:

```bash
dart format .
flutter analyze
flutter test
```

- Never claim something was tested if it wasn't.

## Dependencies

- Keep dependencies minimal.
- Before adding a package, check whether Flutter/Dart or an existing dependency already solves the problem.
- Current dependencies: `http`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `provider` (to add), `mockito` (dev), `build_runner` (dev).
- Do not replace existing dependencies without a concrete reason.

## Design Tokens

- All colors live in `lib/core/theme/app_colors.dart` — never use raw hex values in feature code.
- All theme configuration lives in `lib/core/theme/app_theme.dart`.
- See `docs/architecture.md` for the full token table.

## UI / Design

- Inspect the relevant Figma design before implementing significant UI.
- Match Figma's layout, typography, spacing, colors, components, and states.
- Prefer reusable Flutter components over duplicated UI code.
- Verify important UI changes against the running application.

## Security

- Never store passwords in plaintext — Firebase Auth owns all credentials. See GitHub issue #14.
- Never commit secrets, API keys, or `firebase_options.dart` overrides.

## Code Quality

- Follow standard Dart/Flutter conventions and existing project lints.
- Prefer readable, straightforward code over clever abstractions.
- Do not modify unrelated code.
- Never overwrite or discard existing user changes.

## Debugging

`reproduce → inspect → identify root cause → fix → regression test → validate`

Do not guess or make speculative changes.

## Git

- Keep changes focused and reviewable.
- Inspect the diff before finishing.
- Do not commit unless explicitly asked.
- Always push the branch and open a PR — do not merge directly.
