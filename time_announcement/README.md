# Time Announcement (app)

Flutter app that speaks the current time at scheduled moments. The project
overview lives in the main README: [../README.md](../README.md).

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Android: Android Studio with the Android SDK (compileSdk 36; min SDK 24 via Flutter defaults)
- iOS/macOS: Xcode and CocoaPods (`sudo gem install cocoapods` or `brew install cocoapods`)
- Run `flutter doctor` and resolve any issues it reports.

## Getting started

```sh
flutter pub get   # install dependencies
flutter test      # run unit tests
flutter run       # run on a connected device or emulator
```

## Notes

- Android: scheduled announcements use exact alarms. On Android 12+ the user
  must grant "Alarms & reminders"; on Android 13+ notification permission is required.
- iOS: scheduled announcements are delivered as local notifications with custom sounds.
