# Garden Planner

Flutter app for planning garden terraces, authenticating users with Firebase/Google Sign-In, and persisting terrace layouts in Firestore.

## What has been done so far
- Initial Flutter project scaffolded.
- Firebase backend integration added (auth + terrace persistence).
- Architecture structured with `presentation` (BLoC/UI), `domain` (entities/contracts), and `data` (datasources/repositories).
- `AGENTS.md` created with project architecture and build instructions for Warp agents.
- Google Sign-In flow updated in `lib/data/repositories/firebase_auth_repository_impl.dart`.
- Attempted to create a Warp environment using `oz environment create`, but GitHub authorization is still required for private repo access.

## Development commands
- Install dependencies: `flutter pub get`
- Check connected device/emulator: `flutter devices`
- List emulators: `flutter emulators`
- Launch emulator: `flutter emulators --launch <emulator_id>`
- Run app: `flutter run`
- Static analysis: `flutter analyze`
- Run tests: `flutter test`
- Run one test: `flutter test test/widget_test.dart --plain-name "Counter increments smoke test"`
- Build Android APK: `flutter build apk`

## TODOs (next steps)
- Replace `test/widget_test.dart` default counter smoke test with tests that match current app behavior.
- Confirm and complete GitHub authorization in Warp if you still want to use `oz environment create`.
- Add robust error handling and user feedback for auth failures and Firestore write failures.
- Implement non-placeholder history and terrace detail features (currently partially mock/placeholder).
- Add CI checks for `flutter analyze` and `flutter test`.

## Idea backlog
- Crop lifecycle tracking per terrace (planting date, expected harvest, reminders).
- Offline-first support with local cache + Firestore sync.
- Drag/resize UX improvements with undo history for layout edits.
- Export/share garden layouts.
- Seasonal analytics dashboard by year.

## Notes
- Firebase values are loaded from `.env` through `lib/firebase_options.dart`.
- Android is the currently configured Firebase target platform in code.
