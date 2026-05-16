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
  <img src="https://img.shields.io/badge/Google%20Antigravity-Hackathon-blueviolet" alt="Hackathon" />
</p>

\---

## 🏆 Google Antigravity Hackathon Submission

**Ustaad AI** (powered by **Ustaad AI**) is submitted for **Challenge 2 — AI Service Orchestrator for Informal Economy**.

This is an **agentic AI orchestration platform**, not a simple chatbot. It utilizes Antigravity-inspired multi-agent workflows to perform autonomous service coordination. Users can request local services (electrician, plumber, AC technician, carpenter, etc.) using natural, noisy language in Urdu, Roman Urdu, or English.

The system autonomously:

* Extracts structural intent from conversational requests.
* Discovers nearby providers using deterministic parameters.
* Ranks providers based on distance, rating, and availability.
* Simulates booking workflows and manages conflict handling.
* Automates follow-up and reminder operations.
* Traces execution steps for transparency and reasoning.

\---

## 📖 What is Ustaad AI?

Ustaad AI is built for Pakistan's informal economy, bridging the gap between urban users and local skilled labour. Instead of scrolling through static listings or making phone calls, users simply express their needs naturally.

> \*"Mujhe kal subah G-13 mein AC technician chahiye"\*  
> The AI understands the service type, urgency, location, and seamlessly coordinates the entire booking workflow.

The app supports **two roles**:

* 🏠 **Customer** — Describe what you need in plain language, get matched with providers, and track service workflows autonomously.
* 🔧 **Provider** — Set up your profile with skills \& service area, receive structured customer bookings.

\---

## ✨ Key Features

||Feature|Description|
|-|-|-|
|🤖|**Agentic AI Orchestration**|Conversational UI backed by multi-agent workflows (Google Gemini + Antigravity concepts)|
|🌐|**Multilingual Understanding**|Natively understands Urdu, English, and Roman Urdu|
|🧠|**Smart Intent Parsing**|AI extracts service category, urgency level, budget \& location from unstructured input|
|🎯|**Provider Ranking \& Matching**|Autonomously finds and ranks relevant providers based on skills, location \& availability|
|📅|**Booking Simulation**|Autonomous transaction workflow with real-world failure simulation and retry logic|
|📋|**Workflow Tracing**|Transparent execution logs showing reasoning for provider selection|
|🗺️|**Interactive Map**|Pick your service location on an OpenStreetMap-based map|
|👤|**Profile \& Role Management**|Upload avatar, set skills (providers), manage preferences|
|🔔|**Automated Notifications**|Reminder agent schedules push notifications for upcoming bookings|

\---

## 🏗️ How It Works (Multi-Agent Architecture)

Ustaad AI leverages a structured orchestration pipeline, moving from natural language input to action-oriented execution.

```
User Input (Text / Voice)
       │
       ▼
Flutter Mobile Application
       │
       ▼
Antigravity Workflow Orchestrator
  ├── 🧠 Intent Agent
  ├── 🔍 Discovery Agent
  ├── 📊 Ranking Agent
  ├── 📅 Booking Agent
  └── 🔔 Reminder Agent
       │
       ▼
Gemini + Workflow Logic
       │
       ▼
Mock Provider Database / APIs
       │
       ▼
Booking Simulation + Notifications
```

Unlike basic AI chat wrappers, Ustaad AI is a **workflow orchestration engine**. Each request is passed through a deterministic pipeline of autonomous agents, ensuring reliable action execution rather than just generating conversational text.

\---

## 🧠 Agent Workflow

The "Brain Layer" of Ustaad AI coordinates service fulfillment through five distinct agents:

### 1\. Intent Agent

* **Responsibilities**: Translates raw, multilingual text into a rigid JSON intent schema.
* **Outputs**: Service type, location, time, urgency, and confidence score.
* **Workflow Role**: Validates input. If the confidence is too low, it halts execution and requests clarification from the user.

### 2\. Discovery Agent

* **Responsibilities**: Queries the geospatial provider pool based on the extracted intent.
* **Outputs**: A list of available providers within the user's radius.
* **Workflow Role**: Filters the database to find viable candidates before any complex reasoning occurs.

### 3\. Ranking Agent

* **Responsibilities**: Applies a multi-variable scoring model to the discovered providers.
* **Outputs**: An ordered list of providers, complete with a reasoning explanation for the top pick.
* **Workflow Role**: Makes autonomous decisions based on distance, rating, and availability to select the best match.

### 4\. Booking Agent

* **Responsibilities**: Simulates the transaction and operational reality of booking.
* **Outputs**: Confirmed booking reference, status, and execution logs.
* **Workflow Role**: Attempts the booking. If a provider is simulated as unavailable, it autonomously pulls the next best provider from the Ranking Agent and retries.

### 5\. Reminder Agent

* **Responsibilities**: Automates post-transaction lifecycle events.
* **Outputs**: Scheduled notification queues.
* **Workflow Role**: Dispatches reminders (e.g., T-1 hour) and follow-up surveys to ensure job completion.

\---

## 📜 Agent Trace Example

Ustaad AI generates execution traces to provide transparency into its autonomous decision-making.

```text
\[Intent Agent]
Parsed request successfully. 
Extracted: { "service": "AC technician", "location": "G-13", "urgency": "High" }

\[Discovery Agent]
Found 5 nearby providers within a 5km radius.

\[Ranking Agent]
Selected provider (p\_002) based on:
- Distance: 2.1km
- Rating: 4.8/5.0
- Availability: Open slot at requested time.

\[Booking Agent]
Attempting to book p\_002...
Simulation failed: Provider unavailable.
Retrying with next ranked provider (p\_005)...
Booking workflow completed successfully. Ref: BK-9842X

\[Reminder Agent]
Reminder scheduled successfully for T-1 hour.
```

\---

## 🏢 Multi-Repository Architecture

To maintain a scalable, secure, and production-ready system, the architecture is split across two repositories:

1. **Frontend Repository (This Repo)**

   * Flutter mobile app
   * Mobile workflows, UI, and onboarding
   * Provider interaction and local notifications
   * Firebase Authentication
2. **Backend Repository**

   * Antigravity-inspired orchestration workflow
   * Agent workflows (Intent, Ranking, Booking)
   * Booking simulation and execution tracing
   * Gemini API integration

**Why the split?**

* **Scalability \& Security**: Isolates the sensitive orchestration logic and API keys from the client application.
* **Maintainability**: Allows mobile UI developers and AI backend engineers to iterate independently.
* **Deployment Flexibility**: The mobile app runs natively on Android, while the orchestration engine leverages the edge performance of Vercel and Next.js.

\---

## ⚙️ How Google Antigravity Is Used

Ustaad AI is built entirely around the core concepts of **action-oriented orchestration**. By adopting Antigravity-inspired design patterns, we transform LLMs from passive responders into active executors.

Our workflow strictly follows:
`Input → Understanding → Discovery → Decision-Making → Booking Execution → Follow-Up`

We use **Gemini** for the non-deterministic NLP task (Intent Parsing), and seamlessly hand off the structured output to deterministic workflows (Ranking, Booking) to guarantee speed, reliability, and safe execution.

\---

## 🛠️ Tech Stack

|Layer|Technology|Purpose|
|-|-|-|
|**Frontend**|Flutter (Dart)|Cross-platform mobile UI|
|**Authentication**|Firebase Auth|Google Sign-In|
|**Database**|Cloud Firestore|Chat sessions, service requests, user data|
|**File Storage**|Supabase|Profile image uploads|
|**AI Orchestration**|Next.js + Gemini + Antigravity Workflow Layer|Multi-agent execution, reasoning \& API endpoints|
|**Hosting**|Vercel|Backend API deployment|
|**Maps**|flutter\_map + OpenStreetMap|Location picking|
|**Notifications**|flutter\_local\_notifications|Local push alerts|

\---

## 📂 Project Structure

```
lib/
├── main.dart                     # App entry point \& routing
├── auth\_screen.dart              # Google Sign-In screen
├── config.dart                   # Backend API URL configuration
│
├── models/
│   ├── chat\_session.dart         # Chat session data model
│   ├── labour\_provider.dart      # Provider profile model
│   ├── service\_intent.dart       # AI-parsed intent (category, budget, urgency)
│   ├── service\_request.dart      # Service request with status tracking
│   ├── user\_profile.dart         # User profile model
│   ├── user\_role.dart            # Customer / Provider role enum
│   ├── user\_preferences.dart     # Language \& location preferences
│   └── role\_settings.dart        # Role-specific configuration
│
├── screens/
│   ├── app\_shell.dart            # Bottom navigation \& tab routing
│   ├── customer\_home\_screen.dart # Customer: chat, requests, settings
│   ├── provider\_home\_screen.dart # Provider: dashboard \& incoming requests
│   ├── onboarding\_screen.dart    # First-time user setup
│   └── role\_selection\_screen.dart# Choose Customer or Provider role
│
├── services/
│   ├── chat\_api\_service.dart         # HTTP calls to Vercel backend
│   ├── intent\_parser\_service.dart    # NLP-based intent extraction
│   ├── provider\_matcher\_service.dart # Match providers to customer needs
│   ├── google\_auth\_service.dart      # Firebase Google Auth wrapper
│   ├── session\_repository.dart       # Firestore chat session CRUD
│   ├── requests\_repository.dart      # Firestore service request CRUD
│   ├── preferences\_repository.dart   # Firestore user preferences
│   ├── profile\_repository.dart       # Firestore user profiles
│   ├── storage\_service.dart          # Supabase file uploads
│   ├── profile\_image\_processor.dart  # Image compression before upload
│   └── notification\_service.dart     # Local notification scheduling
│
├── widgets/
│   ├── app\_logo.dart             # Animated logo widget
│   ├── requests\_panel.dart       # Service requests list view
│   ├── settings\_panel.dart       # Settings \& preferences panel
│   ├── provider\_match\_card.dart  # Provider search result card
│   ├── profile\_avatar.dart       # User avatar with upload
│   ├── location\_picker\_sheet.dart# Location selection bottom sheet
│   └── map\_picker\_screen.dart    # Full-screen map picker
│
└── theme/
    └── app\_colors.dart           # App-wide color palette
```

\---

## 🚀 Build \& Run

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

> \*\*Note:\*\* This project requires Firebase and Supabase configuration files to run.
> These are gitignored for security. See the example files in the repo for reference.

\---

## 🔗 Related Repositories

|Repository|Description|Deployment|
|-|-|-|
|[**KarigarAI-App**](https://github.com/Mitul-Dial/KarigarAI-App)|Flutter mobile app (this repo)|Android APK|
|[**KarigarAI**](https://github.com/Mitul-Dial/KarigarAI)|Next.js + Antigravity Backend API|[Vercel](https://karigar-ai-nu.vercel.app)|

\---

## 👥 Team Members

* **Mitul Dial**
* **Muhammad Raqib Shakil**
* **Muhammad Abubakar**
* **Mubeen Khalid**

\---

<p align="center">
  <b>Built for the Google Antigravity Hackathon</b>
</p>

