# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development commands
- Install dependencies: `flutter pub get`
- Verify active target device: `flutter devices`
- If no device is active, list and launch an emulator:
  - `flutter emulators`
  - `flutter emulators --launch <emulator_id>`
- Run app: `flutter run`
- Analyze: `flutter analyze`
- Run all tests: `flutter test`
- Run one test file: `flutter test test/widget_test.dart`
- Run one named test: `flutter test test/widget_test.dart --plain-name "Counter increments smoke test"`
- Build Android APK: `flutter build apk`
- Re-generate Firebase options when config/platform support changes: `flutterfire configure`

## Required runtime configuration
- The app loads `.env` at startup (`lib/main.dart`) and reads Firebase values from `lib/firebase_options.dart`.
- Ensure `.env` contains:
  - `FIREBASE_API_KEY`
  - `FIREBASE_APP_ID`
  - `FIREBASE_MESSAGING_SENDER_ID`
  - `FIREBASE_PROJECT_ID`
  - `FIREBASE_STORAGE_BUCKET`
- `DefaultFirebaseOptions.currentPlatform` is configured only for Android; other platforms currently throw `UnsupportedError`.

## Architecture overview
- The project follows a layered structure:
  - `lib/presentation`: UI pages and BLoCs (state/event handling)
  - `lib/domain`: core entities and repository interfaces
  - `lib/data`: repository implementations, data sources, and models
  - `lib/core/theme`: app theme tokens and styling
- Dependency direction is intentionally one-way:
  - `presentation` depends on `domain`.
  - `data` implements `domain` repositories.
  - `domain` stays framework/data-source independent.

## Startup and dependency wiring
- `lib/main.dart` is the composition root:
  - Initializes Flutter bindings, loads `.env`, initializes Firebase.
  - Registers repositories with `MultiRepositoryProvider`.
  - Registers `AuthBloc` and `TerraceBloc` with `MultiBlocProvider`.
  - Routes to `LoginScreen` or `HomeScreen` from auth state.

## State management flow
- Auth flow:
  - `AuthBloc` handles `CheckAuthStatusEvent`, `SignInWithGoogleEvent`, `SignOutEvent`.
  - Uses `AuthRepository` (implemented by `FirebaseAuthRepositoryImpl`).
- Terrace layout flow:
  - `TerraceBloc` handles loading, adding terraces, drag updates, save/reset.
  - Maintains both `_savedTerraces` and `_currentTerraces` to track unsaved edits.
  - Persists only on `SaveLayout`; `ResetLayout` discards in-memory changes.

## Data and external integrations
- Firestore persistence:
  - `FirestoreDataSource` reads/writes `users/{userId}/terraces`.
  - `saveTerraces` writes each terrace document by terrace ID via batch set.
- Plant lookup:
  - `PlantApiService` calls OpenFarm (`https://openfarm.cc/api/v1/crops?filter=...`).
  - `PlantSearchScreen` uses this directly (outside the auth/terrace repository abstraction).
- Google sign-in:
  - Implemented in `FirebaseAuthRepositoryImpl` using `google_sign_in` + Firebase credential sign-in.

## Current implementation caveats to know before editing
- `test/widget_test.dart` is still the default counter smoke test and does not match the current app behavior.
- `FirebaseAuthDataSource.signInWithGoogle()` is intentionally unimplemented; production sign-in is handled in `FirebaseAuthRepositoryImpl`.
- Several UI areas are placeholder/mock-oriented (for example history and parts of terrace details), so verify expected behavior before expanding those flows.
