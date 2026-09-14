# Cafe Management

Flutter cafe management app ("Brew"). Figma is the UI source of truth: `https://www.figma.com/make/1MrydbK8RMEHYHWHzmq8FL/`
When Figma and existing implementation differ, follow Figma for visual design unless there is a documented technical constraint.

## Architecture
See `docs/architecture.md` (folder structure, naming, patterns, design tokens).

- `lib/features/<feature>/models|services|state|screens|widgets/`
- Shared code → `lib/widgets/` or `lib/core/`. No cross-feature imports.
- Services: plain Dart, no Flutter deps. State (ChangeNotifiers) calls services. Screens call state only.
- Colors: `lib/core/theme/app_colors.dart`. No raw hex in feature code.

## Git
- New branch per task: `feat/`, `fix/`, `chore/`, `test/`, `refactor/` prefix.
- Never commit to `main`. Push branch, open PR.
- Do not commit unless explicitly asked.

## Quality
Run after every change: `dart format . && flutter analyze`

## Security
Firebase Auth owns all credentials. Never commit secrets or `firebase_options.dart`.
