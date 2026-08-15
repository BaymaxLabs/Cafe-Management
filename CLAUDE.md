# Cafe Management

Small Flutter mobile application developed primarily with Claude Code.

## Source of Truth

* **Figma** is the source of truth for UI/UX.
* Existing code is the source of truth for established project conventions.
* When Figma and existing implementation differ, follow Figma for visual design unless there is a documented technical constraint.

## Architecture

* Prefer simple, feature-first architecture.
* Keep UI, state/business logic, and data access separated.
* UI must not directly access APIs, databases, or persistence.
* Don't introduce layers, abstractions, or patterns until they are actually needed.
* Reuse existing components before creating new ones.

## UI / Design

* Inspect the relevant Figma design before implementing significant UI.
* Match Figma's layout, typography, spacing, colors, components, and states.
* Centralize repeated design values such as colors, typography, spacing, and radii.
* Prefer reusable Flutter components over duplicated UI code.
* Verify important UI changes against the running application.

## Dependencies

* Keep dependencies minimal.
* Before adding a package, check whether Flutter/Dart or an existing dependency already solves the problem.
* Do not replace existing dependencies without a concrete reason.
* Current networking dependency: `http`.

## Code Quality

* Follow standard Dart/Flutter conventions and existing project lints.
* Prefer readable, straightforward code over clever abstractions.
* Do not modify unrelated code.
* Never overwrite or discard existing user changes.

## Debugging

When debugging:

`reproduce → inspect → identify root cause → fix → regression test → validate`

Do not guess or make speculative changes.

## Validation

Before completing a task:

```bash
dart format .
flutter analyze
flutter test
```

For UI changes, run the app and verify the affected flow.

Never claim something was tested if it wasn't.

## Git

* Keep changes focused and reviewable.
* Inspect the diff before finishing.
* Do not commit unless explicitly asked.
