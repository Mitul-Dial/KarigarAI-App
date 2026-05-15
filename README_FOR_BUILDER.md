# Ustaad AI - APK Build Instructions

Hello! Your friend's laptop ran out of disk space while trying to build the Android APK, so they need your help to compile it. Everything is already set up and coded; you just need to run the build commands.

## What you (the builder) need to have installed:
1.  **Flutter SDK** (and it must be added to your system PATH).
2.  **Android Studio** (specifically the Android SDK, Build-Tools, and NDK installed via Android Studio's SDK Manager).
3.  Ensure your `flutter doctor` command shows no errors for Android development.

---

## Instructions to Build the APK

### 1. Extract the Project
Extract the `ustaad_ai_app.zip` folder that your friend sent you to any location on your computer (e.g., your Desktop or Documents).

### 2. Open Terminal in the Project Folder
Open your terminal (Command Prompt, PowerShell, or VS Code terminal) and navigate into the extracted folder:
```bash
cd path\to\ustaad_ai_app
```

### 3. Clean and Get Dependencies
Run the following commands to ensure all previous caches are cleared and the required Flutter packages are downloaded fresh:
```bash
flutter clean
flutter pub get
```

### 4. Build the Release APK
Now, run the command to build the professional, optimized Android APK:
```bash
flutter build apk --release
```

**Note:** This step might take 2-10 minutes depending on your computer's speed. It will download the Android NDK and other build tools if you don't already have them.

### 5. Locate the APK and Send it Back
Once the build is complete, you will find the final APK file here:
`ustaad_ai_app\build\app\outputs\flutter-apk\app-release.apk`

Send this `app-release.apk` file back to your friend!

---

## Important Info / Keys (For Reference)
You shouldn't need to change anything because the project is already configured, but here are the details in case you run into issues:

*   **Backend Server URL:** `https://karigar-ai-nu.vercel.app` (This is already set inside `lib/config.dart`).
*   **Keystore File:** The app is signed using `ustaad-ai-key.jks` which is included in the project folder.
*   **Keystore Passwords:** `ustaad123` (These are already configured in `android/key.properties`).
*   **App ID:** `com.example.ustaad_ai_app` (must match Firebase / google-services.json)

Thank you for your help!
