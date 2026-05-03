# Garden Planner

Flutter app for planning garden beds, authenticating users with Firebase/Google Sign-In, and persisting garden layouts in Firestore.

## Project structure
- `lib/main.dart`: app entrypoint, loads `.env`, initializes Firebase, wires repositories and BLoCs.
- `lib/presentation`: UI pages, widgets, and BLoCs.
- `lib/domain`: core entities and repository interfaces.
- `lib/data`: Firebase/Trefle datasources, models, and repository implementations.
- `lib/core/theme`: theme tokens and shared styling.
- `test/plant_api_service_test.dart`: focused, meaningful test suite for plant search.
- `test/widget_test.dart`: still default counter test and currently stale.

## Runtime flow
- App starts in `lib/main.dart`.
- `GardenPlannerApp` registers `AuthRepository` and `GardenRepository`.
- `AuthBloc` drives login state.
- `GardenBloc` loads garden data after auth succeeds.
- Home screen shows garden canvas and editing flow.

## Data and integrations
- Firestore persists default garden at `users/{userId}/gardens/{gardenId}` with terraces in `terraces` subcollection.
- `FirestoreGardenDataSource` still falls back to legacy garden data if new garden document does not exist.
- Plant search uses Trefle API, not OpenFarm.
- Firebase config values come from `.env` through `lib/firebase_options.dart`.
- Only Android Firebase options are configured in code today.

## Development commands
- Install dependencies: `flutter pub get`
- Check connected device/emulator: `flutter devices`
- List emulators: `flutter emulators`
- Launch emulator: `flutter emulators --launch <emulator_id>`
- Run app: `flutter run`
- Static analysis: `flutter analyze`
- Run tests: `flutter test`
- Run focused plant search tests: `flutter test test/plant_api_service_test.dart`
- Build Android APK: `flutter build apk`

## Planning
- TODOs and idea backlog live in `BACKLOG.md`.

## Known quirks
- Firebase values are loaded from `.env` through `lib/firebase_options.dart`.
- Android is currently only configured Firebase target in code.
- `flutter test` currently fails because `test/widget_test.dart` builds app without Firebase initialization.
