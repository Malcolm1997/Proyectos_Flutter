# Copilot instructions for Texel IoT (mobile_app)

This repository contains three top-level areas:
- `mobile_app/` — Flutter application (primary active code in this repo).
- `backend_local/` — backend placeholder (currently empty; expected local service code).
- `firmware_equipo/` — firmware placeholder (currently empty; device firmware goes here).

Goal for AI coding agents
- Be immediately productive on the Flutter app: add features, modify UI, and wire platform integrations.
- Preserve platform runner files and generated plugin registrants; make minimal, well-scoped edits to native host code only when needed.

Big-picture architecture (what you'll find and why)
- UI + app logic: `mobile_app/lib/` (single entry at [mobile_app/lib/main.dart](mobile_app/lib/main.dart#L1)).
- Conventions: UI pieces live under `mobile_app/lib/components/`; app/core logic under `mobile_app/lib/core/`.
- Platform embedding: native host code lives under each platform folder (e.g. [windows/runner/flutter_window.cpp](windows/runner/flutter_window.cpp#L1), `ios/Runner/`, `android/app/`). Plugin registration files are generated under platform-specific `Flutter/` directories — avoid hand-editing those.

Developer workflows (concrete commands)
- Setup (Windows):

  - `cd mobile_app`
  - `flutter pub get`

- Run locally (Windows desktop):

  - `cd mobile_app`
  - `flutter run -d windows`

- Run on Android emulator / device:

  - `flutter emulators --launch <name>` (if needed)
  - `flutter run -d <device-id>`

- Build release artifacts:

  - Android: `flutter build apk`
  - iOS (mac only): `flutter build ios --no-codesign`

- Linting / analysis / tests:

  - `flutter analyze`
  - `flutter test`

Notes on dependency changes
- Add dependencies to [mobile_app/pubspec.yaml](mobile_app/pubspec.yaml#L1) and run `flutter pub get` in `mobile_app/`.
- The project uses `flutter_lints`; follow its patterns and prefer null-safe packages compatible with Dart SDK ^3.10.0.

Project-specific conventions and pitfalls
- Keep UI components small and stateless under `lib/components/`; put shared logic and models under `lib/core/`.
- `lib/main.dart` is intentionally simple — newer screens, routes, and state management are expected to be added under `lib/`.
- Do not modify files in `*/Flutter/` generated folders; change plugin or host initialization in the `Runner/` / `runner/` folders for each platform instead.
- Platform-specific behavior should be implemented in the native runner and exposed via platform channels or platform packages.

Integration points and cross-component communication
- Native plugins: check `GeneratedPluginRegistrant.*` in each platform folder to see which plugins are registered.
- If generating a new plugin or native API, update the appropriate `Runner/` (iOS/macOS) or `runner/` (Windows/Linux) host file and ensure the plugin is added to `pubspec.yaml`.
- Backend / firmware: this repo includes placeholders for `backend_local/` and `firmware_equipo/` — coordinate with maintainers before adding backend services or firmware artifacts here.

Examples (quick references)
- Entry point: [mobile_app/lib/main.dart](mobile_app/lib/main.dart#L1)
- Package manifest: [mobile_app/pubspec.yaml](mobile_app/pubspec.yaml#L1)
- Windows runner: [windows/runner/flutter_window.cpp](windows/runner/flutter_window.cpp#L1)

What to do when you don't have platform tools available
- If you don't have Xcode or Android SDK locally, still implement Dart/Flutter changes and unit tests; run `flutter analyze` and `flutter test`.

If you change platform/native code
- Document why the native change was required in the PR description and include minimal reproduction steps for reviewers.

When to ask maintainers
- Before introducing a new third-party service, backend API, or firmware format to the repo.
- Before changing any CI/build scripts or platform runner behavior.

Questions / feedback
- If any section is unclear or you need additional examples (e.g., how platform channels are wired here), ask and I will iterate.
