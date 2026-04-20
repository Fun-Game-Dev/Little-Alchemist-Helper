# Contributing to Little Alchemist Helper

Thank you for contributing.

## Ground Rules

- Keep all repository content and pull request communication in English.
- Keep changes focused and small when possible.
- Update docs when behavior or workflows change.
- Add or update tests for non-trivial logic changes.

## Development Setup

1. Install Flutter stable.
2. Clone the repository.
3. Run:

```bash
flutter pub get
flutter analyze
flutter test
```

## Branch and PR Workflow

1. Create a branch from `main`.
2. Use clear commit messages.
3. Open a pull request with:
   - What changed
   - Why it changed
   - How you tested it
4. Ensure CI is green before requesting review.

## Coding Guidelines

- Follow `flutter_lints`.
- Prefer explicit typing in shared/public APIs.
- Keep widgets small and composable.
- Avoid mixing business logic directly into UI widgets.

## Reporting Bugs and Requesting Features

- Use GitHub Issues and the provided templates.
- Include reproduction steps, expected behavior, and actual behavior.
