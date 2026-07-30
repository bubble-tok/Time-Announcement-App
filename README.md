# Time Announcement

A Flutter mobile app that speaks the current time out loud at scheduled moments throughout the day — so you always know what time it is without looking at your phone.

Unlike a regular alarm, Time Announcement doesn't need to be dismissed or turned off. It just quietly announces the time in the background, on a schedule you set, so you can stay aware of time passing without breaking focus to check your screen.

> **Status:** In active development (beta). Currently a single global schedule with an ON/OFF toggle and volume control; per-day custom scheduling is a planned future enhancement. See [Current Progress](#current-progress) below for exactly what's built so far.

## Key Features

| Feature | Description |
|---|---|
| Scheduled announcements | Announces the time via text-to-speech at set times throughout the day |
| Global ON/OFF toggle | Silence all announcements with a single switch |
| Volume control | Follow the device's system volume, or set a custom app volume |
| Permission handling | Detects and guides you through fixing missing notification/alarm permissions |

## Tech Stack

| Component | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Text-to-speech | `flutter_tts` |
| Scheduled notifications | `flutter_local_notifications` |
| Local storage | `shared_preferences` |
| State management | `provider` |

## Why this project is a bit different

This isn't just an app — it's a full software development lifecycle practiced end to end. Alongside the Flutter code, this repo includes:

- **[Functional requirements](docs/2_functional_requirements.md)** and **[non-functional requirements](docs/3_nonfunctional_requirements.md)**
- **[Architecture & data model docs](docs/4_architecture.md)**, including a documented plan for how the app evolves post-beta (e.g. swapping local storage for a Firebase backend without touching UI code)
- A **[UML class diagram](docs/5_uml_diagram.md)** and **[UI mockups](docs/6_ui_mockup.md)**
- A **[test plan](docs/7_test_plan.md)**
- A Jira backlog tracking the beta scope cut and deferred future work

The goal was to practice building software the way a small product team would — requirements and design decisions written down before code, not just after.

## Current Progress

**Done:**
- Permission handling (notifications, exact-alarm) with status UI and a guided fix-it flow to device Settings
- Local persistence layer (`SharedPreferences`-backed), built behind an abstract interface so the storage backend can be swapped later without touching the UI
- Home screen ON/OFF toggle, wired to persisted state
- The announcement schedule's data model (fixed hourly announcements, 9 AM – 10 PM, in beta)

**In progress / up next:**
- Wiring the schedule to Android/iOS's notification scheduler
- Connecting scheduled notifications to actually trigger text-to-speech
- Unit tests for time formatting and the announcement condition logic

## Getting Started

```bash
cd time_announcement
flutter pub get
flutter run
```

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install). See [`time_announcement/pubspec.yaml`](time_announcement/pubspec.yaml) for the exact dependency versions.
