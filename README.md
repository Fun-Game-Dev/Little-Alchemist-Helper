# Little Alchemist Helper

Little Alchemist Helper is a Flutter mobile app that helps players manage decks, browse card collections, explore combo data, and track time-based game rotations.

## Features

- Deck management and editing tools
- Collection browser with filtering and sorting
- Combo Lab for checking combo outcomes
- Timed events screens (portal, arena shop, seasonal packs)
- Import/export-friendly local data workflows
- Optional wiki image loading and external wiki linking

## Tech Stack

- Flutter (Dart, null-safe)
- Provider for state management
- SharedPreferences for local settings
- HTTP + cached image pipeline for external media

## Getting Started

### Prerequisites

- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Xcode (for iOS builds)
- Android Studio / Android SDK (for Android builds)

### Setup

```bash
flutter pub get
flutter run
```

## Development Commands

```bash
flutter analyze
flutter test
```

## Project Structure

```text
lib/
  models/       # Data models and domain types
  services/     # Data loaders and external service integrations
  state/        # App-level state and controllers
  ui/           # Screens, widgets, and app shell
  util/         # Shared helper utilities
assets/
  data/         # Static game datasets
  images/       # App images and pack visuals
  icons/        # Feature-specific icon sets
```

## Contributing

Contributions are welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening a pull request.

## Security

If you discover a security issue, please follow the process in [`SECURITY.md`](SECURITY.md).

## Code of Conduct

This project follows the Contributor Covenant. See [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

## License

This project is licensed under the MIT License. See [`LICENSE`](LICENSE).
