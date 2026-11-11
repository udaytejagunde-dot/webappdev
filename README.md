# WebDev Code Library (Flutter)

A beginner-friendly Flutter app for the Web Application Development (Front-End) course.

## Included modules
1. HTML, CSS & JavaScript
2. React Basics
3. Components & State
4. Routing
5. APIs & Advanced

The initial library contains the 20 hands-on and case-study programs supplied in the conversation.

## Features
- Search by title, description, or module
- Filter by module and by Hands-on / Case Study
- View selectable source code
- Copy code to clipboard
- Read a short expected-output description
- Light and dark themes
- Course data stored locally in `assets/data/programs.json`
- No code execution

## Run in Android Studio / VS Code
1. Install Flutter SDK and configure Android Studio.
2. Extract this ZIP.
3. Open the `webdev_code_library` folder in Android Studio or VS Code.
4. Run `flutter pub get` in the terminal.
5. Run `flutter run` or select an emulator/device.

## Build Android APK
```bash
flutter build apk --release
```
APK output:
`build/app/outputs/flutter-apk/app-release.apk`

## Run as a web app
```bash
flutter run -d chrome
```

## Build web release
```bash
flutter build web
```

## Add more programs later
Add another object to `assets/data/programs.json` using the same fields as the existing entries. Module numbers are 1 to 5. The app reads this JSON at startup.

## Notes
- React / JSX and HTML examples are displayed as text; this Flutter app does not run them.
- The public API example in the course code requires internet when that example is run in its original React environment.
- This project uses only Flutter's SDK and `cupertino_icons`; it does not need a syntax-highlighting package or a backend.
# Web_app_frontend_course
# Web_app_frontend_course
