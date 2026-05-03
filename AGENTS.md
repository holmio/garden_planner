# AGENTS.md

## Commands
- Install deps: `flutter pub get`
- Check devices: `flutter devices`
- List / launch emulators: `flutter emulators`, `flutter emulators --launch <emulator_id>`
- Run app: `flutter run`
- Static analysis: `flutter analyze`
- Run all tests: `flutter test`
- Run the only currently reliable focused suite: `flutter test test/plant_api_service_test.dart`
- Build Android APK: `flutter build apk`
- If Firebase targets/config change, regenerate `lib/firebase_options.dart`: `flutterfire configure`

## Runtime Setup
- `lib/main.dart` always loads `.env` before Firebase init; `.env` is declared as a Flutter asset in `pubspec.yaml`.
- Required `.env` keys for app startup on Android: `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET`.
- Plant search also needs `TREFLE_API_TOKEN`; missing it throws a `PlantApiException` from `PlantApiService`.
- Google sign-in optionally reads `GOOGLE_SIGN_IN_SERVER_CLIENT_ID` from `.env`.
- `DefaultFirebaseOptions.currentPlatform` only returns Android options. Web, desktop, and iOS currently throw `UnsupportedError`.

## Architecture
- `lib/main.dart` is the composition root. It registers `AuthRepository` and `GardenRepository`, creates `AuthBloc` and `GardenBloc`, and dispatches `LoadGarden` after auth succeeds.
- The current domain is `garden`, not the older `terrace`-only naming. Core layers are:
  - `lib/presentation`: pages, widgets, BLoCs
  - `lib/domain`: entities and repository interfaces
  - `lib/data`: Firebase/Trefle datasources, models, repository implementations
  - `lib/core/theme`: app theme tokens
- `GardenBloc` keeps both `_savedGarden` and `_currentGarden`; `ResetGarden` restores the saved snapshot and `SaveGarden` is the only persistence path.

## Persistence And Integrations
- Firestore now persists the default garden at `users/{userId}/gardens/{gardenId}` with terraces in the `terraces` subcollection.
- `FirestoreGardenDataSource.getGarden()` still falls back to the legacy shape `users/{userId}/garden/settings` plus `users/{userId}/terraces` if the new garden document does not exist yet.
- Plant search uses Trefle (`https://trefle.io/api/v1/...`), not OpenFarm.
- `FirebaseAuthDataSource.signInWithGoogle()` is intentionally unimplemented; the real sign-in flow lives in `FirebaseAuthRepositoryImpl` via `GoogleSignIn.instance` and Firebase Auth.

## Testing Quirks
- `flutter analyze` passes as of 2026-05-03.
- `flutter test` currently fails because `test/widget_test.dart` is still the default counter test and pumps `GardenPlannerApp` without Firebase initialization.
- `test/plant_api_service_test.dart` is the meaningful existing suite; use it for focused verification when touching plant search.

## Docs Maintenance
- If a change affects project structure, app wiring, major directories, runtime flow, or core integrations, ask user whether README should be updated.
- If user confirms structure/runtime docs should stay current, update `README.md` in same task before finishing.
- After completing work, check `BACKLOG.md`. If delivered change matches an item there, remove that item from the backlog as part of the same task.
- Do not remove backlog items for partial progress; only remove them when the implemented change fully satisfies the item.

## Optional Response Mode
- If user asks for `caveman` mode, check `.opencode\skills\caveman\SKILL.md` and follow its response-style rules manually.
- If user says `stop caveman`, stop following that file and return to normal response style.
