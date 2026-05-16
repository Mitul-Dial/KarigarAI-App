<p align="center">
  <img src="assets/app_logo.png" alt="Ustaad AI Logo" width="120" />
</p>

<h1 align="center">Ustaad AI</h1>

<p align="center">
  <strong>AI-Powered Skilled Labour Orchestration Platform</strong><br/>
  Autonomous service coordination for Pakistan's informal economy.
</p>

<p align="center">
<img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart" />
<img src="https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase" alt="Firebase" />
<img src="https://img.shields.io/badge/Supabase-Storage-3ECF8E?logo=supabase" alt="Supabase" />
<img src="https://img.shields.io/badge/Google%20Gemini-AI-4285F4?logo=google" alt="Gemini AI" />
<img src="https://img.shields.io/badge/Next.js-Backend-0000FF?logo=nextdotjs" alt="Next.js" />
<img src="https://img.shields.io/badge/Vercel-Hosting-444444?logo=vercel" alt="Vercel" />
<img src="https://img.shields.io/badge/Multi--Agent-Orchestration-blueviolet" alt="Multi-Agent" />
<img src="https://img.shields.io/badge/Google%20Antigravity-Hackathon-purple" alt="Google Antigravity" />
</p>

---

## 🏆 Google Antigravity Hackathon Submission

**Ustaad AI** is submitted for **Challenge 2 — AI Service Orchestrator for Informal Economy**.

This is an **agentic AI orchestration platform**, not a simple chatbot. It utilizes Google Antigravity multi-agent orchestration workflows to autonomously coordinate service discovery, provider matching, booking simulation, and follow-up workflows.

Users can request local services (electrician, plumber, AC technician, carpenter, etc.) using natural, noisy language in Urdu, Roman Urdu, or English.

The system autonomously:

- Extracts structured intent from conversational requests
- Discovers nearby providers using deterministic parameters
- Ranks providers based on distance, rating, and availability
- Simulates booking workflows and manages conflict handling
- Automates follow-up and reminder operations
- Generates execution traces for transparency and reasoning

---


## 📖 What is Ustaad AI?

**Ustaad AI** is an Android app built for Pakistan’s informal economy, making it easier to connect users with local skilled workers through conversational AI.

Instead of scrolling through listings or making multiple phone calls, users simply describe what they need naturally.

> *"Mujhe kal subah G-13 mein AC technician chahiye"*  
> The AI understands the service type, urgency, location, and seamlessly coordinates the booking workflow.

The app supports **two roles**:

- 🏠 **Customer** — Describe what you need, get matched with providers, and track service workflows autonomously
- 🔧 **Provider** — Set up your profile with skills & service area, receive structured customer bookings

---

## ✨ Key Features

| | Feature | Description |
|---|---------|-------------|
| 🤖 | **Agentic AI Orchestration** | Conversational UI backed by multi-agent workflows (Gemini + Antigravity concepts) |
| 🌐 | **Multilingual Understanding** | Supports Urdu, English, and Roman Urdu |
| 🧠 | **Smart Intent Parsing** | Extracts service category, urgency, budget & location from natural language |
| 🎯 | **Provider Ranking & Matching** | Finds and ranks providers based on skills, location & availability |
| 📅 | **Booking Simulation** | Simulates booking workflows with retry logic and conflict handling |
| 📋 | **Workflow Tracing** | Transparent execution logs showing reasoning and workflow state |
| 🗺️ | **Interactive Map** | Pick service location using OpenStreetMap |
| 👤 | **Profile & Role Management** | Upload avatar, manage preferences, configure provider skills |
| 🔔 | **Automated Notifications** | Reminder agent schedules booking reminders and updates |
| 🎨 | **Onboarding Flow** | Smooth onboarding with role selection and preference setup |

---

## 🏗️ How It Works (Multi-Agent Architecture)
Ustaad AI leverages a structured orchestration pipeline, moving from natural language input to action-oriented execution.

```
┌──────────────────────────────────────────────────────────────┐
│                    Ustaad AI Mobile App                      │
│                       (Flutter / Dart)                       │
│                                                              │
│   Customer chats ──► AI parses intent                        │
│                           └──► Matches providers             │
│                                   └──► Creates request       │
└───────────────┬──────────────────┬───────────────────────────┘
                │                  │
                ▼                  ▼
        ┌────────────────┐   ┌──────────────────────┐
        │   Firebase     │   │      Supabase        │
        │ Auth +         │   │      Storage         │
        │ Firestore      │   │     (Avatars)        │
        └────────────────┘   └──────────────────────┘
                               │
                               ▼
                ┌──────────────────────────────────┐
                │ Antigravity Workflow Backend     │
                │          + Gemini                |
                │          (Hosted on Vercel)      |
                ├──────────────────────────────────┤
                │ 🧠 Intent Agent                  │
                │ 🔍 Discovery Agent               │
                │ 📊 Ranking Agent                 │
                │ 📅 Booking Agent                 │
                │ 🔔 Reminder Agent                │
                └──────────────────────────────────┘
                               │
                               ▼
                ┌──────────────────────────────────┐
                │ Provider Matching                │
                │ Booking Simulation               │
                │ Follow-Up Automation             │
                │ Execution Tracing                │
                └──────────────────────────────────┘
```
The app communicates with a **backend API** deployed on Vercel that connects to Google Gemini for AI responses. The backend is maintained in a separate repository:

🔗 **Backend Repo:** [Mitul-Dial/KarigarAI](https://github.com/Mitul-Dial/KarigarAI) — deployed at `karigar-ai-nu.vercel.app`

---
## 🧠 Agent Workflow

The "Brain Layer" of Ustaad AI coordinates service fulfillment through five distinct agents:

### 1. Intent Agent

**Responsibilities:**  
Translates raw, multilingual text into a rigid JSON intent schema.

**Outputs:**  
Service type, location, time, urgency, and confidence score.

**Workflow Role:**  
Validates input. If the confidence is too low, it halts execution and requests clarification from the user.

---

### 2. Discovery Agent

**Responsibilities:**  
Queries the geospatial provider pool based on the extracted intent.

**Outputs:**  
A list of available providers within the user's radius.

**Workflow Role:**  
Filters the database to find viable candidates before any complex reasoning occurs.

---

### 3. Ranking Agent

**Responsibilities:**  
Applies a multi-variable scoring model to the discovered providers.

**Outputs:**  
An ordered list of providers, complete with a reasoning explanation for the top pick.

**Workflow Role:**  
Makes autonomous decisions based on distance, rating, and availability to select the best match.

---

### 4. Booking Agent

**Responsibilities:**  
Simulates the transaction and operational reality of booking.

**Outputs:**  
Confirmed booking reference, status, and execution logs.

**Workflow Role:**  
Attempts the booking. If a provider is simulated as unavailable, it autonomously pulls the next best provider from the Ranking Agent and retries.

---

### 5. Reminder Agent

**Responsibilities:**  
Automates post-transaction lifecycle events.

**Outputs:**  
Scheduled notification queues.

**Workflow Role:**  
Dispatches reminders (e.g., T-1 hour) and follow-up surveys to ensure job completion.

---

## 📜 Agent Trace / Logs

Ustaad AI generates structured execution traces to provide transparency into autonomous decision-making, agent interactions, and workflow execution.

The orchestration pipeline logs:

- 🧠 Reasoning steps
- 🤝 Agent-to-agent interactions
- ⚙️ Action execution workflows
- 🔄 Retry & fallback handling
- 📋 Booking lifecycle events

### Example Execution Trace

```text
[Intent Agent]
Parsed request successfully.
Extracted:
{
  "service": "AC technician",
  "location": "G-13",
  "urgency": "High"
}

[Discovery Agent]
Found 5 nearby providers within a 5km radius.

[Ranking Agent]
Selected provider (p_002) based on:
- Distance: 2.1km
- Rating: 4.8/5.0
- Availability: Open slot at requested time.

[Booking Agent]
Attempting to book p_002...
Simulation failed: Provider unavailable.
Retrying with next ranked provider (p_005)...
Booking workflow completed successfully.
Ref: BK-9842X

[Reminder Agent]
Reminder scheduled successfully for T-1 hour.
```
<img width="792" height="700" alt="image" src="https://github.com/user-attachments/assets/d626596c-bf47-47dd-9c41-d0e9b43a04b3" />

🔗 For additional orchestration logs and backend workflow traces, visit:

[https://karigar-ai-nu.vercel.app/](https://karigar-ai-nu.vercel.app/)


---
## 🏢 Multi-Repository Architecture

To maintain a scalable, secure, and production-ready system, the architecture is split across two repositories:

### Frontend Repository (This Repo)

- Flutter mobile app
- Mobile workflows, UI, and onboarding
- Provider interaction and local notifications
- Firebase Authentication

---

### Backend Repository

- Google Antigravity orchestration workflow
- Agent workflows (Intent, Ranking, Booking)
- Booking simulation and execution tracing
- Gemini API integration

---

### Why the split?

#### 🔒 Scalability & Security
Isolates the sensitive orchestration logic and API keys from the client application.

#### 🛠️ Maintainability
Allows mobile UI developers and AI backend engineers to iterate independently.

#### 🚀 Deployment Flexibility
The mobile app runs natively on Android, while the orchestration engine leverages the edge performance of Vercel and Next.js.

---
## ⚙️ How Google Antigravity Is Used

Ustaad AI is built entirely around the core concepts of action-oriented orchestration. Built directly around Google Antigravity design principles, we transform LLMs from passive responders into active executors.

Our workflow strictly follows:

```text
Input
→ Understanding
→ Discovery
→ Decision-Making
→ Booking Execution
→ Follow-Up
```
We use Gemini for the non-deterministic NLP task (Intent Parsing), and seamlessly hand off the structured output to deterministic workflows (Ranking, Booking) to guarantee speed, reliability, and safe execution.

This architecture enables:

- Multi-agent reasoning
- Autonomous workflow execution
- Structured decision-making
- Booking simulation
- Execution tracing
- Follow-up automation

Instead of functioning as a simple chatbot, Ustaad AI coordinates real-world inspired service workflows through a transparent orchestration pipeline.

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter (Dart) | Cross-platform mobile UI |
| **Authentication** | Firebase Auth | Google Sign-In |
| **Database** | Cloud Firestore | Chat sessions, service requests, user data |
| **File Storage** | Supabase | Profile image uploads |
| **AI Orchestration** | Next.js + Gemini + Antigravity Workflow Layer | Multi-agent orchestration, reasoning & workflow execution |
| **Hosting** | Vercel | Backend API deployment |
| **Maps** | flutter_map + OpenStreetMap | Location picking |
| **Notifications** | flutter_local_notifications | Local push alerts |

---

## 📂 Project Structure

```text
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
│   └── role_selection_screen.dart # Choose Customer or Provider role
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
│   ├── location_picker_sheet.dart # Location selection bottom sheet
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

## 👥 Team Members

- Mitul Dial
- Muhammad Raqib Shakil
- Muhammad Abubakar
- Mubeen Khalid

---

<p align="center">
  <b>Built for the Google Antigravity Hackathon</b>
</p>
