<p align="center">
  <img src="assets/app_logo.png" alt="Ustaad AI Logo" width="120" />
</p>

<h1 align="center">Ustaad AI</h1>

<p align="center">
  <strong>Your AI-Powered Skilled Labour Platform</strong><br/>
  Connecting customers with trusted service providers through intelligent chat.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase" alt="Firebase" />
  <img src="https://img.shields.io/badge/Supabase-Storage-3ECF8E?logo=supabase" alt="Supabase" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android" alt="Android" />
</p>

---

## 📖 About

**Ustaad AI** is a mobile application that uses AI-powered chat to connect customers with skilled labour providers (electricians, plumbers, carpenters, etc.). Instead of manually browsing listings, users simply describe what they need in natural language — the AI understands their intent, finds matching providers nearby, and helps them submit service requests.

### 🔗 Backend Repository

> The backend API for this app is maintained in a **separate repository** and deployed on Vercel.
> 
> **Backend Repo:** [Mitul-Dial/KarigarAI](https://github.com/Mitul-Dial/KarigarAI)  
> **Live API:** `https://karigar-ai-nu.vercel.app`

This repo contains **only the Flutter mobile app**. Pushing here does not affect the backend deployment.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🤖 **AI Chat** | Natural language conversations powered by Google Gemini via the backend API |
| 🔐 **Google Sign-In** | One-tap authentication using Firebase Auth |
| 👤 **Dual Roles** | Users can be a **Customer** (request services) or a **Provider** (offer services) |
| 📋 **Service Requests** | AI parses chat to create structured service requests with category, urgency & budget |
| 🗺️ **Location Picker** | Interactive map-based location selection for service areas |
| 🔔 **Notifications** | Local push notifications for request updates |
| 🖼️ **Profile Management** | Avatar upload & profile editing with Supabase storage |
| 🎨 **Onboarding** | Smooth onboarding flow with role selection and preference setup |
| 💬 **Chat Sessions** | Persistent chat history stored in Firestore |

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────┐
│                   Flutter App (this repo)             │
│                                                       │
│  ┌─────────┐  ┌──────────┐  ┌──────────────────────┐ │
│  │ Screens  │  │ Widgets  │  │      Services        │ │
│  │          │  │          │  │                      │ │
│  │ Customer │  │ Chat UI  │  │ Chat API Service     │ │
│  │ Provider │  │ Settings │  │ Intent Parser        │ │
│  │ Auth     │  │ Requests │  │ Provider Matcher     │ │
│  │ Onboard  │  │ Map Pick │  │ Google Auth          │ │
│  └────┬─────┘  └────┬─────┘  └──────────┬───────────┘ │
│       │              │                   │             │
└───────┼──────────────┼───────────────────┼─────────────┘
        │              │                   │
        ▼              ▼                   ▼
   ┌─────────┐   ┌──────────┐      ┌─────────────┐
   │ Firebase │   │ Supabase │      │ Vercel API  │
   │ Auth +   │   │ Storage  │      │ /api/chat   │
   │ Firestore│   │ (Avatars)│      │ (Gemini AI) │
   └─────────┘   └──────────┘      └─────────────┘
                                    (separate repo)
```

---

## 📂 Project Structure

```
lib/
├── main.dart                  # App entry point & routing
├── auth_screen.dart           # Google Sign-In screen
├── config.dart                # Backend API URL config
├── config/
│   ├── supabase_config.dart   # Supabase connection setup
│   └── supabase_secrets.dart  # 🔒 Gitignored — keys here
├── models/
│   ├── chat_session.dart      # Chat session model
│   ├── labour_provider.dart   # Provider profile model
│   ├── service_intent.dart    # Parsed AI intent model
│   ├── service_request.dart   # Service request model
│   ├── user_profile.dart      # User profile model
│   ├── user_role.dart         # Customer / Provider enum
│   ├── user_preferences.dart  # Language & location prefs
│   └── role_settings.dart     # Role-specific settings
├── screens/
│   ├── app_shell.dart         # Bottom nav + tab routing
│   ├── customer_home_screen.dart  # Customer chat & requests
│   ├── provider_home_screen.dart  # Provider dashboard
│   ├── onboarding_screen.dart     # First-time setup
│   └── role_selection_screen.dart  # Choose Customer/Provider
├── services/
│   ├── chat_api_service.dart       # HTTP calls to Vercel backend
│   ├── intent_parser_service.dart  # NLP intent extraction
│   ├── provider_matcher_service.dart # Match providers to requests
│   ├── google_auth_service.dart    # Firebase Google Auth
│   ├── session_repository.dart     # Firestore chat sessions
│   ├── requests_repository.dart    # Firestore service requests
│   ├── preferences_repository.dart # Firestore user preferences
│   ├── profile_repository.dart     # Firestore user profiles
│   ├── storage_service.dart        # Supabase file uploads
│   ├── profile_image_processor.dart # Image compression
│   └── notification_service.dart   # Local notifications
├── widgets/
│   ├── app_logo.dart           # Animated logo widget
│   ├── requests_panel.dart     # Service requests list
│   ├── settings_panel.dart     # Settings & preferences
│   ├── provider_match_card.dart # Provider result card
│   ├── profile_avatar.dart     # User avatar widget
│   ├── location_picker_sheet.dart # Location bottom sheet
│   └── map_picker_screen.dart  # Full-screen map picker
├── theme/
│   └── app_colors.dart         # App color palette
└── utils/
    └── profile_validators.dart # Input validation
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (Dart) |
| **Auth** | Firebase Authentication (Google Sign-In) |
| **Database** | Cloud Firestore |
| **Storage** | Supabase (profile images) |
| **AI Backend** | Next.js + Google Gemini (on Vercel — [separate repo](https://github.com/Mitul-Dial/KarigarAI)) |
| **Maps** | flutter_map + OpenStreetMap |
| **Notifications** | flutter_local_notifications |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x+)
- [Android Studio](https://developer.android.com/studio) (for Android SDK & emulator)
- [Git](https://git-scm.com/downloads)

Verify your setup:

```bash
flutter doctor
```

### Clone & Install

```bash
git clone https://github.com/Mitul-Dial/KarigarAI-App.git
cd KarigarAI-App
flutter pub get
```

### Configure Secrets

The following files are **gitignored** for security. You must obtain them from the project lead:

| File | How to get it |
|------|---------------|
| `android/app/google-services.json` | Download from [Firebase Console](https://console.firebase.google.com) → Project Settings |
| `lib/config/supabase_secrets.dart` | Copy `supabase_secrets.example.dart` and fill in your Supabase URL & anon key |
| `android/key.properties` | Copy `key.properties.example` and fill in keystore passwords (release builds only) |
| `android/*.jks` | Signing keystore file (release builds only) |

### Run

```bash
# Debug on connected device / emulator
flutter run

# Build release APK
flutter build apk --release
```

Release APK output: `build/app/outputs/flutter-apk/app-release.apk`

---

## ⚙️ Configuration

### Backend URL

The app connects to the Vercel backend defined in `lib/config.dart`. To use a different backend:

```bash
flutter run --dart-define=API_BASE_URL=https://your-custom-backend.vercel.app
```

### Firebase Setup

1. Create a project in [Firebase Console](https://console.firebase.google.com)
2. Enable **Authentication** → **Google** sign-in method
3. Add your Android app with package name `com.example.ustaad_ai_app`
4. Add SHA-1 and SHA-256 fingerprints for Google Sign-In to work
5. Download `google-services.json` and place in `android/app/`
6. Publish `firestore.rules` under Firestore → Rules

---

## 🔒 Security

The `.gitignore` is configured to prevent leaking sensitive files:

- ✅ `google-services.json` — Firebase API keys
- ✅ `firebase_options.dart` — Firebase platform configs
- ✅ `supabase_secrets.dart` — Supabase credentials
- ✅ `key.properties` & `*.jks` — Android signing keys
- ✅ `.env` files — Environment variables

> **Never commit API keys, service account JSONs, or signing keystores to Git.**  
> Share them with teammates via a password manager or encrypted channel.

---

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "Add your feature"`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a **Pull Request**

### Branch Convention

| Branch | Purpose |
|--------|---------|
| `main` | Stable release — only merge reviewed PRs |
| `feature/*` | New features |
| `fix/*` | Bug fixes |

---

## 📋 Quick Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Run in debug mode
flutter analyze              # Static analysis
flutter build apk --release  # Build release APK
flutter test                 # Run tests
```

---

## 🔗 Related Repositories

| Project | Repository | Deployment |
|---------|-----------|------------|
| **Mobile App** | **This repo** | Android APK |
| **Backend API** | [Mitul-Dial/KarigarAI](https://github.com/Mitul-Dial/KarigarAI) | [Vercel](https://karigar-ai-nu.vercel.app) |

---

## 📄 License

This project is for educational purposes.

---

<p align="center">
  Built with ❤️ using Flutter & Firebase
</p>
