<p align="center">
  <img src="assets/app_logo.png" alt="Ustaad AI Logo" width="120" />
</p>

<h1 align="center">Ustaad AI</h1>

<p align="center">
  <strong>AI-Powered Skilled Labour Marketplace</strong><br/>
  Find electricians, plumbers, carpenters & more — just by chatting.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase" alt="Firebase" />
  <img src="https://img.shields.io/badge/Supabase-Storage-3ECF8E?logo=supabase" alt="Supabase" />
  <img src="https://img.shields.io/badge/Google%20Gemini-AI-4285F4?logo=google" alt="Gemini AI" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android" alt="Android" />
</p>
-
---

## 📖 What is Ustaad AI?

**Ustaad AI** is an Android app that makes finding skilled workers as easy as sending a text message. Instead of scrolling through listings or making phone calls, you just tell the AI what you need in plain language — and it handles the rest.

> *"Mujhe kal subah ek electrician chahiye, budget 2000 tak"*  
> The AI understands the service type, urgency, budget, and finds matching providers near you.

The app supports **two roles**:
- 🏠 **Customer** — Describe what you need, get matched with providers, track service requests
- 🔧 **Provider** — Set up your profile with skills & service area, receive customer requests

---

## ✨ Key Features

| | Feature | Description |
|---|---------|-------------|
| 🤖 | **AI-Powered Chat** | Conversational interface powered by Google Gemini — understands Urdu, English, and Roman Urdu |
| 🔐 | **Google Sign-In** | One-tap login with your Google account |
| 🧠 | **Smart Intent Parsing** | AI extracts service category, urgency level, budget & location from natural conversation |
| 🔍 | **Provider Matching** | Automatically finds relevant providers based on skills, location & availability |
| 📋 | **Service Requests** | Structured request system with status tracking (pending → accepted → completed) |
| 🗺️ | **Interactive Map** | Pick your service location on an OpenStreetMap-based map |
| 👤 | **Profile Management** | Upload avatar, set skills (providers), manage preferences |
| 🔔 | **Notifications** | Local push notifications for request updates |
| 🎨 | **Onboarding Flow** | Smooth first-time setup with role selection and preference configuration |

---

## 🏗️ How It Works

```
┌─────────────────────────────────────────────────┐
│              Ustaad AI Mobile App               │
│                (Flutter / Dart)                  │
│                                                  │
│   Customer chats ──► AI parses intent            │
│                      ──► Matches providers       │
│                          ──► Creates request     │
└──────────┬──────────┬────────────────┬───────────┘
           │          │                │
           ▼          ▼                ▼
      ┌─────────┐ ┌──────────┐  ┌───────────┐
      │Firebase │ │ Supabase │  │ Next.js   │
      │Auth +   │ │ Storage  │  │ Backend   │
      │Firestore│ │(Avatars) │  │ + Gemini  │
      └─────────┘ └──────────┘  └───────────┘
                                 (on Vercel)
```

The app communicates with a **backend API** deployed on Vercel that connects to Google Gemini for AI responses. The backend is maintained in a separate repository:

🔗 **Backend Repo:** [Mitul-Dial/KarigarAI](https://github.com/Mitul-Dial/KarigarAI) — deployed at `karigar-ai-nu.vercel.app`

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter (Dart) | Cross-platform mobile UI |
| **Authentication** | Firebase Auth | Google Sign-In |
| **Database** | Cloud Firestore | Chat sessions, service requests, user data |
| **File Storage** | Supabase | Profile image uploads |
| **AI Backend** | Next.js + Google Gemini | Natural language understanding & responses |
| **Hosting** | Vercel | Backend API deployment |
| **Maps** | flutter_map + OpenStreetMap | Location picking |
| **Notifications** | flutter_local_notifications | Local push alerts |

---

## 📂 Project Structure

```
lib/
├── main.dart                     # App entry point & routing
├── auth_screen.dart              # Google Sign-In screen
├── config.dart                   # Backend API URL configuration
│
├── models/
│   ├── chat_session.dart         # Chat session data model
│   ├── labour_provider.dart      # Provider profile model
│   ├── service_intent.dart       # AI-parsed intent (category, budget, urgency)
│   ├── service_request.dart      # Service request with status tracking
│   ├── user_profile.dart         # User profile model
│   ├── user_role.dart            # Customer / Provider role enum
│   ├── user_preferences.dart     # Language & location preferences
│   └── role_settings.dart        # Role-specific configuration
│
├── screens/
│   ├── app_shell.dart            # Bottom navigation & tab routing
│   ├── customer_home_screen.dart # Customer: chat, requests, settings
│   ├── provider_home_screen.dart # Provider: dashboard & incoming requests
│   ├── onboarding_screen.dart    # First-time user setup
│   └── role_selection_screen.dart# Choose Customer or Provider role
│
├── services/
│   ├── chat_api_service.dart         # HTTP calls to Vercel backend
│   ├── intent_parser_service.dart    # NLP-based intent extraction
│   ├── provider_matcher_service.dart # Match providers to customer needs
│   ├── google_auth_service.dart      # Firebase Google Auth wrapper
│   ├── session_repository.dart       # Firestore chat session CRUD
│   ├── requests_repository.dart      # Firestore service request CRUD
│   ├── preferences_repository.dart   # Firestore user preferences
│   ├── profile_repository.dart       # Firestore user profiles
│   ├── storage_service.dart          # Supabase file uploads
│   ├── profile_image_processor.dart  # Image compression before upload
│   └── notification_service.dart     # Local notification scheduling
│
├── widgets/
│   ├── app_logo.dart             # Animated logo widget
│   ├── requests_panel.dart       # Service requests list view
│   ├── settings_panel.dart       # Settings & preferences panel
│   ├── provider_match_card.dart  # Provider search result card
│   ├── profile_avatar.dart       # User avatar with upload
│   ├── location_picker_sheet.dart# Location selection bottom sheet
│   └── map_picker_screen.dart    # Full-screen map picker
│
└── theme/
    └── app_colors.dart           # App-wide color palette
```

---

## 🚀 Build & Run

```bash
# Clone the repo
git clone https://github.com/Mitul-Dial/KarigarAI-App.git
cd KarigarAI-App

# Install dependencies
flutter pub get

# Run on emulator or connected device
flutter run

# Build release APK
flutter build apk --release
```

> **Note:** This project requires Firebase and Supabase configuration files to run.
> These are gitignored for security. See the example files in the repo for reference.

---

## 🔗 Related Repositories

| Repository | Description | Deployment |
|-----------|-------------|------------|
| **[KarigarAI-App](https://github.com/Mitul-Dial/KarigarAI-App)** | Flutter mobile app (this repo) | Android APK |
| **[KarigarAI](https://github.com/Mitul-Dial/KarigarAI)** | Next.js backend API + Gemini AI | [Vercel](https://karigar-ai-nu.vercel.app) |

---

<p align="center">
  A <b>Mitul Dial's</b> Project
</p>
