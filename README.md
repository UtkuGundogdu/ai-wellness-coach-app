# AI Wellness Coach App

Health and wellness focused Flutter application built for the Flutter Academy case study. Users can pick from multiple AI coaches, chat with persona-driven assistants, and resume previous conversations from local history.

## Features

- Bottom navigation with `Coaches` and `Chat History` tabs
- 4 AI coaches with distinct personas:
  - Dietitian
  - Fitness Coach
  - Pilates Instructor
  - Yoga Teacher
- Dynamic coach system instructions loaded from Firebase Remote Config
- Firebase AI chat integration through `firebase_ai`
- Local chat history persistence with `SharedPreferences`
- Resume previous conversations with preserved context
- Cubit-based state management with UI/business logic separation

## Architecture

The project uses a lightweight feature-based structure:

```text
lib/
  app/
  core/
    di/
    models/
    repositories/
    services/
  features/
    chat/
    coaches/
    history/
    navigation/
```

### Main decisions

- `Cubit` is used for bottom navigation, chat history loading, and active chat state.
- `CoachRepository` handles coach catalog data plus persona/model lookup from Remote Config.
- `ChatRepository` is responsible for local persistence and delegating AI response streaming.
- `FirebaseAiChatService` initializes the Vertex AI model with the system instruction fetched from Remote Config.
- Firebase initialization errors are handled gracefully so the app still opens without committed config files.

## Firebase setup

Do not commit Firebase configuration files. This repository already ignores:

- `google-services.json`
- `GoogleService-Info.plist`
- `firebase_options.dart`

When connecting your own Firebase project, make sure:

1. Firebase is added to the Android/iOS app.
2. Firebase AI and Remote Config are enabled in the project.
3. The following Remote Config keys exist:

- `vertex_model_name`
- `vertex_location`
- `coach_persona_dietitian`
- `coach_persona_fitness`
- `coach_persona_pilates`
- `coach_persona_yoga`

### Suggested default values

- `vertex_model_name`: `gemini-2.5-flash`
- `vertex_location`: `us-central1`

## Local run

```bash
flutter pub get
flutter run
```

On Windows, Flutter plugin symlink creation may require Developer Mode to be enabled.

## Screenshots

Add your running app screenshots or a short GIF here before submission:

- `docs/screenshots/coaches.png`
- `docs/screenshots/chat.png`
- `docs/screenshots/history.png`

## Notes

- The current workspace intentionally does not include Firebase config files.
- Because of that, UI and local persistence can be reviewed immediately, while live AI responses require your own Firebase project connection.
