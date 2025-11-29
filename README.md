# Mini Social Feed (Starter Project)

This repository is a starter **professional**-UI Flutter project that implements the required architecture
and core features from the task:

- Feature-based structure (auth, posts)
- dio client with Auth Interceptor (access + refresh token rotation)
- get_it dependency injection
- flutter_bloc for state management
- secure storage for tokens
- file picker and permissions support

## What is included
- `lib/` skeleton with main files: `main.dart`, DI, dio client + interceptor, example cubits, repositories and models.
- `pubspec.yaml` with required dependencies.
- `README.md` with setup notes.

## How to use
1. Install Flutter SDK.
2. Copy this project into your workspace.
3. Run `flutter pub get`.
4. Replace API base URL in `lib/core/constants/api_constants.dart`.
5. Run on a device or emulator.

## Notes
- This is a functional skeleton and not a full finished product. It includes the full Auth interceptor logic and retry flow.
- Fill UI widgets and expand features as needed. The structure follows the task requirements so you can continue development easily.
