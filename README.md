# Rumour Room

Anonymous room-code chat built with Flutter and Firebase Cloud Firestore.

## Features

- Join an existing room or create a room by entering a 6-digit code.
- Fetch an anonymous identity from `https://randomuser.me/api/`.
- Persist identity locally per room, so the same device rejoins the same room with the same generated user.
- Send and receive realtime text messages through Firestore snapshot listeners.
- Use server timestamps for message ordering and display.
- Show date separators in chat history.
- Load paginated chat history while keeping the latest messages live.
- Keep previously loaded chat visible offline with Firestore persistence.
- Track room members with idempotent membership updates.

## Codebase Structure

```text
lib/
  main.dart
  src/
    app.dart
    core/
      cubit/              Shared base cubits and paginated list state
      di/                 GetIt dependency registration
      error/              Exceptions and failures
      network/            REST and Firestore client abstractions
      router/             auto_route route definitions
      services/           Local storage and connectivity services
      theme/              App palette, typography, and themes
      utils/              App bootstrap and helpers
    features/
      identity/           Per-room randomuser identity fetch/cache flow
      join_room/          Room-code validation and join/create flow
      chat/               Firestore chat stream, pagination, composer, UI
    presentation/         Shared atoms and molecules
```

Each feature follows a simple layered shape:

```text
data/         Datasources, DTOs, repository implementations
domain/       Entities, repository contracts, use cases
presentation/ Cubits, screens, widgets
```

## Firebase Cloud Firestore Data Structure

```text
rooms/{roomCode}
  code: string
  createdAt: timestamp
  memberIds: string[]
  memberCount: number

rooms/{roomCode}/messages/{messageId}
  text: string
  authorId: string
  authorUsername: string
  sentAt: timestamp
```

`memberIds` and `memberCount` are updated together in a Firestore transaction. Rejoining the same room from the same device reuses the cached identity, so the count does not increase again for the same user.

## Local Data Structure

Room identity is stored in `SharedPreferences` using a per-room key:

```text
rumour.identity:{roomCode}
```

Cached value:

```json
{
  "id": "randomuser-login-uuid",
  "displayName": "First Last",
  "username": "generated_username",
  "avatarUrl": "https://..."
}
```

## Realtime and Offline Behavior

Chat messages are read from:

```text
rooms/{roomCode}/messages
```

The app listens with Firestore `.snapshots(includeMetadataChanges: true)`, so new messages, local pending writes, and server-confirmed writes update the UI automatically. Message queries explicitly order by `sentAt` and then document id, because Firestore does not guarantee collection storage order without `orderBy`. Firestore persistence is enabled during app startup, allowing previously loaded chat data to appear again without connectivity.

## Suggested Firestore Rules for Evaluation

Use rules appropriate for the assignment/demo project. A permissive demo-only version:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /rooms/{roomId} {
      allow read, create, update: if true;

      match /messages/{messageId} {
        allow read, create: if true;
      }
    }
  }
}
```

These rules are not production-safe because the app does not use Firebase Auth.

## Running

```bash
flutter pub get
flutter run
```

The Android Firebase config is expected at:

```text
android/app/google-services.json
```

## Validation

```bash
dart analyze
flutter test
```

## APK

Pending final stable build.

Expected location after building:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Demo Video

Pending final stable recording.
