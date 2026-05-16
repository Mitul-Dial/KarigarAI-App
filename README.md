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

This is an **agentic AI orchestration platform**, not a simple chatbot. It uses a structured multi-agent pipeline built around Google Antigravity principles to autonomously coordinate service discovery, provider matching, booking simulation, and follow-up workflows.

Users can request local services (electrician, plumber, AC technician, carpenter, etc.) using natural, noisy language in Urdu, Roman Urdu, or English.

The system autonomously:

- Extracts structured intent from conversational requests
- Discovers nearby providers using real or simulated geospatial parameters
- Ranks providers based on distance, rating, and availability
- Simulates booking workflows and manages conflict handling
- Automates follow-up and reminder operations
- Generates execution traces for transparency and reasoning

---

## 📖 What is Ustaad AI?

**Ustaad AI** is an Android app built for Pakistan's informal economy, making it easier to connect users with local skilled workers through conversational AI.

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
| 🤖 | **Agentic AI Orchestration** | Conversational UI backed by multi-agent workflows (Gemini + Antigravity) |
| 🌐 | **Multilingual Understanding** | Supports Urdu, English, and Roman Urdu |
| 🧠 | **Smart Intent Parsing** | Extracts service category, urgency, budget & location from natural language |
| 🎯 | **Provider Ranking & Matching** | Finds and ranks providers based on skills, location & availability |
| 📅 | **Booking Simulation** | Simulates booking workflows with retry logic and conflict handling |
| 📋 | **Workflow Tracing** | Transparent execution logs showing reasoning and workflow state |
| 🗺️ | **Interactive Map** | Pick service location using OpenStreetMap |
| 👤 | **Profile & Role Management** | Upload avatar, manage preferences, configure provider skills |
| 🔔 | **Automated Notifications** | Reminder agent schedules booking reminders and updates |
| 💳 | **Escrow Payment Simulation** | 20% deposit held in simulated escrow, released on job completion |
| 🎨 | **Onboarding Flow** | Smooth onboarding with role selection and preference setup |

---

## 🏗️ How It Works (Multi-Agent Architecture)

Ustaad AI leverages a structured orchestration pipeline, moving from natural language input to action-oriented execution. Instead of a monolithic script, the system functions as a sequential pipeline of autonomous agents. Each agent receives structured input, performs isolated reasoning, and passes a strict JSON contract to the next agent. The orchestrator maintains a global trace logger that captures every decision, confidence score, and fallback execution.

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
                │   Antigravity Workflow Backend   │
                │       + Gemini 2.5 Flash         │
                │       (Hosted on Vercel)         │
                ├──────────────────────────────────┤
                │ 🔐 Auth Layer                    │
                │ 🧭 Orchestrator (DAG Controller) │
                │ 🧠 Intent Agent                  │
                │ 🔍 Discovery Agent               │
                │ 📊 Ranking Agent                 │
                │ 📅 Booking Agent                 │
                │ 🔔 Reminder + Notification Agent │
                │ 💳 Payment (Escrow) Layer        │
                │ 📍 Location Layer                │
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

## ⚙️ How Google Antigravity Is Used

Antigravity is the backbone of Ustaad AI's autonomous execution. The core orchestration is implemented in `lib/antigravity.ts` via the `AntigravityWorkflow` class, which acts as a multi-step directed acyclic graph (DAG) controller. By structuring the orchestration as a DAG, context continuity is ensured — each agent's output becomes the next agent's validated input, and the shared `TraceLog` provides end-to-end visibility across the entire workflow.

**Gemini 2.5 Flash** is called at three critical non-deterministic stages:

1. **Intent Parsing** — The raw multilingual user message is sent to Gemini with a strict `responseSchema` (JSON schema enforcement via `responseMimeType: "application/json"`). This guarantees typed structured output (service, location, time, urgency, language, clarificationPrompt) and prevents hallucination in the agent-to-agent handoff.

2. **Provider Selection** — After deterministic distance and availability filtering, Gemini reasons over the shortlisted candidates and selects the best match, explaining its decision in the user's detected language (English, Urdu, or Roman Urdu).

3. **Booking Simulation** — Gemini simulates a realistic 90% success / 10% failure rate for the booking attempt, generating a booking ID and contextual confirmation message if successful.

**Deterministic TypeScript agents** handle all non-NLP stages — Ranking math, Payment Escrow, Auth validation, Location tracking, and Follow-up scheduling — to guarantee speed, predictability, and safe execution.

The `/api/orchestrate` endpoint acts as the DAG controller: it validates the session via `AuthLayer`, adapts to network conditions (2G / 3G / WiFi lite modes), enforces role-based access (customers cannot trigger provider actions and vice versa), and routes the workflow to the appropriate agent chain. Every agent writes to a shared `traces[]` array, which is returned to the client as a full execution log.

Our workflow strictly follows:

```
Input
→ Auth Validation
→ Intent Understanding  (Gemini)
→ Provider Discovery    (Maps API / Haversine fallback)
→ Ranking & Selection   (Deterministic scoring + Gemini)
→ Booking Execution     (Simulated)
→ Escrow Payment        (Simulated)
→ Follow-Up & Notifications
→ Execution Trace Output
```

---

## 🧠 Agent Workflow

The Brain Layer of Ustaad AI coordinates service fulfillment through five distinct agents:

### 1. Intent Agent

**Responsibilities:**
Translates raw, multilingual, informal text (e.g. "Bhai electrician bhejo") into a rigid structured intent schema using Gemini 2.5 Flash with enforced JSON response schema. Normalizes spelling, detects urgency context ("urgent hai" → urgency: high), identifies partial information across conversation history, and calculates a confidence score.

**Input:**
```json
{ "raw_text": "mujhe kal subah G-13 mein AC technician chahiye" }
```

**Output:**
```json
{
  "service_type": "AC technician",
  "location": "G-13",
  "time": "tomorrow morning",
  "urgency": "medium",
  "language": "Roman Urdu",
  "parsed_entities": ["kal subah", "G-13", "AC technician"],
  "confidence": 0.92,
  "missing_fields": [],
  "clarification_needed": false
}
```

**Workflow Role:**
Validates input. If `confidence < 0.6` or required fields (service, location, time) are missing, it halts execution and returns a `clarificationPrompt` in the user's detected language before the pipeline continues.

---

### 2. Discovery Agent

**Responsibilities:**
Queries the geospatial provider pool based on the extracted intent. Attempts real geocoding and Distance Matrix calculations via the Google Maps API. Falls back to a deterministic hash-based distance model if the API key is unavailable or the call fails. Providers with no available slots are excluded at this stage.

**Provider Dataset:**
The backend uses a dataset of **100 mock providers** covering Islamabad and Rawalpindi, generated using Google Antigravity (`providers.json`). Each provider record includes service category, real-area coordinates, rating, available time slots, base price, cost-per-km, and spoken languages.

**Output:**
A list of available providers filtered by service category, with real-world or simulated distances and price estimates attached.

**Workflow Role:**
Filters the provider pool to viable candidates before any Gemini reasoning occurs, ensuring the ranking agent only evaluates relevant, available options.

---

### 3. Ranking Agent

**Responsibilities:**
Applies a deterministic multi-variable scoring model to the discovered providers, then uses Gemini to select the best match and generate a human-readable explanation in the user's language.

**Scoring Formula (Weighted Linear Combination):**
```
Base Score:  100
− (distance_km × 5)    → distance penalty    (closer is better)
+ (rating × 5)         → rating bonus
+ 20                   → urgency bonus (if urgency = high AND slot available today)
+ 5                    → language match bonus
```

Score ties are broken by distance (closer wins). The reasoning trace logs the exact math applied to the top 3 candidates, making the ranking fully auditable.

**Input:** Output from the Discovery Agent

**Output:**
```json
{
  "shortlisted_providers": [
    {
      "provider_id": "p_002",
      "name": "Kamran AC Services",
      "rank": 1,
      "score": 85.5,
      "reason": "Closest distance (2km) with tomorrow morning availability and high rating (4.8)."
    }
  ],
  "fallback_suggestions_needed": false
}
```

**Workflow Role:**
Makes autonomous decisions based on quantified factors. Gemini selects the top provider and explains the choice in the user's detected language without exposing internal scores or system details.

---

### 4. Booking Agent

**Responsibilities:**
Simulates the transaction and operational reality of booking using a Gemini call to model realistic provider acceptance behaviour (90% success, 10% failure rate).

**Input:**
```json
{ "selected_provider": { "..." }, "requested_time": "tomorrow morning" }
```

**Output:**
```json
{
  "booking_reference": "BK-9842X",
  "provider_id": "p_002",
  "status": "confirmed",
  "confirmed_slot": "10:00 AM",
  "attempts": 1,
  "execution_log": ["Attempted p_002 at 10:00 AM → Confirmed"]
}
```

**Workflow Role:**
Attempts the booking. If the provider is simulated as unavailable, it autonomously pulls the next ranked provider from the shortlist and retries (up to 3 attempts). If all candidates are exhausted, orchestration aborts gracefully with a full failure log. After a confirmed booking, a **20% escrow deposit** is processed via the Payment Layer (JazzCash mock), held until job completion.

---

### 5. Follow-Up & Notification Agent

**Responsibilities:**
Automates the complete post-booking lifecycle. After a confirmed booking, two events are scheduled: a `T−60 min` arrival reminder and a `T+120 min` completion survey. The Notification Agent generates typed `NotificationPayload` objects for each event with multilingual content (English, Urdu, Roman Urdu) and routes them across the appropriate channels based on user preferences.

**Notification Behaviour:**
- Booking confirmation → `CRITICAL` priority, delivered immediately via In-App + Push + SMS (per user preferences)
- Arrival reminders → `CRITICAL`, always delivered
- Completion surveys → `SECONDARY`, grouped to reduce notification fatigue, suppressed during quiet hours if `quietHoursEnabled` is set

**Input:** Output from the Booking Agent

**Output:**
```json
{
  "schedule": [
    {
      "trigger_time": "T-60",
      "action_type": "REMINDER",
      "message": "Reminder: Your AC technician is arriving soon."
    },
    {
      "trigger_time": "T+120",
      "action_type": "SURVEY",
      "message": "Has the work been completed? Please rate your experience."
    }
  ]
}
```

---

## 🔄 End-to-End Workflow Example

1. **User:** "Plumber near me today"
2. **Intent Agent:** Parses `{ service: "plumber", time: "today", urgency: "medium" }` with confidence 0.91.
3. **Discovery Agent:** Queries the 100-provider dataset. Finds 3 plumbers. Rashid Plumbing is 1.2km away with a slot at 14:00.
4. **Ranking Agent:** Scores Rashid Plumbing at 92 (1.2km distance, 4.9 rating, today availability). Selects as top pick.
5. **Booking Agent:** Simulates booking request. Confirmed for 14:00. Booking ID: `BK-47291`.
6. **Payment Layer:** 20% deposit (PKR 360) locked in escrow via JazzCash simulation.
7. **Follow-Up Agent:** Queues arrival reminder for 13:00. Queues completion survey for 16:00.
8. **Result:** UI updates incrementally with agent cards, ending at "Booking Confirmed."

---

## 📜 Agent Trace / Logs

Ustaad AI generates structured execution traces to provide full transparency into autonomous decision-making, agent interactions, and workflow execution. Every layer — Auth, Orchestrator, Agent, Payment, Booking, Location — writes timestamped entries to a shared `traces[]` array returned with every API response.

The orchestration pipeline logs:

- 🧠 Reasoning steps and confidence scores
- 🤝 Agent-to-agent handoffs with JSON contracts
- ⚙️ Action execution and tool calls (Maps API, Gemini)
- 🔄 Retry & fallback handling
- 💳 Payment escrow lifecycle events
- 📋 Booking confirmation and scheduling

### Agent-Level Trace (Retry / Fallback Flow)

This simplified view shows how agent names and fallback steps appear when a booking conflict occurs:

```json
[
  {"timestamp": "10:01:02", "agent": "Orchestrator",    "action": "Received input",          "data": "Bhai electrician bhejo.."},
  {"timestamp": "10:01:04", "agent": "IntentParser",    "action": "Parsed Intent",           "status": "Success", "confidence": 0.88},
  {"timestamp": "10:01:05", "agent": "ProviderMatcher", "action": "Ranked 3 candidates",     "status": "Success", "top_pick": "p_005"},
  {"timestamp": "10:01:06", "agent": "BookingAgent",    "action": "Attempting p_005",        "status": "Failed",  "reason": "Slot conflict"},
  {"timestamp": "10:01:07", "agent": "BookingAgent",    "action": "Attempting fallback p_008","status": "Confirmed"},
  {"timestamp": "10:01:08", "agent": "FollowUpAgent",   "action": "Scheduled webhooks",      "status": "Completed"}
]
```

### Full Layered Trace (Production Format)

The production `/api/orchestrate` endpoint returns a richer trace with layer tags, covering Auth, Payment, and Location in addition to agents:

```json
[
  {"timestamp": "10:01:00", "layer": "Auth",         "action": "Validating OAuth 2.0 Session Token",           "status": "Success"},
  {"timestamp": "10:01:01", "layer": "Orchestrator", "action": "Ingesting Context and Parsing Intent",          "status": "Pending"},
  {"timestamp": "10:01:02", "layer": "Agent",        "action": "Starting Intent Parser Agent",                  "status": "Pending"},
  {"timestamp": "10:01:04", "layer": "Agent",        "action": "Intent Parsed (Roman Urdu)",                    "status": "Success",
    "data": {"service": "AC technician", "location": "G-13", "urgency": "high", "isComplete": true}},
  {"timestamp": "10:01:05", "layer": "Location",     "action": "Geocoding location: G-13",                      "status": "Pending"},
  {"timestamp": "10:01:06", "layer": "Location",     "action": "Acquired real-world distances via Google Maps",  "status": "Success"},
  {"timestamp": "10:01:07", "layer": "Agent",        "action": "Provider Matched: Kamran AC Services",          "status": "Success",
    "data": {"distanceKm": 2.1, "rating": 4.8, "score": 85.5}},
  {"timestamp": "10:01:08", "layer": "Booking",      "action": "Starting Booking Agent",                        "status": "Pending"},
  {"timestamp": "10:01:09", "layer": "Booking",      "action": "Booking Confirmed",                             "status": "Success",
    "data": {"bookingId": "BK-9842X", "estimatedCost": 2605}},
  {"timestamp": "10:01:10", "layer": "Payment",      "action": "Initiating Escrow Deposit via JAZZCASH",        "status": "Pending"},
  {"timestamp": "10:01:11", "layer": "Payment",      "action": "Deposit Locked in Escrow Trust Account",        "status": "Success",
    "data": {"amount": 521, "status": "HELD_IN_ESCROW"}},
  {"timestamp": "10:01:12", "layer": "Orchestrator", "action": "Workflow completed.",                            "status": "Success"}
]
```

🔗 For live orchestration logs and backend workflow traces, visit: [https://karigar-ai-nu.vercel.app/](https://karigar-ai-nu.vercel.app/)

---

## 🏢 Multi-Repository Architecture

To maintain a scalable, secure, and production-ready system, the architecture is split across two repositories:

### Frontend Repository (This Repo)

- Flutter mobile app
- Mobile workflows, UI, and onboarding
- Client-side intent parsing (`intent_parser_service.dart`) with Roman Urdu/English keyword matching and edit-distance fuzzy matching
- Client-side provider ranking (`provider_matcher_service.dart`) for fast local matching
- Firebase Authentication (Google Sign-In)
- Local notification scheduling

### Backend Repository

- `AntigravityWorkflow` class — the core DAG orchestration engine (`lib/antigravity.ts`)
- Agent pipeline: Intent (Gemini) → Discovery (Maps API) → Ranking (Gemini) → Booking (Gemini) → Follow-up
- Auth Layer with session validation and role-based access control
- Payment Layer with JazzCash escrow simulation
- Location Layer with geofencing and provider arrival tracking
- Offline sync queue for low-connectivity environments
- Execution trace logging returned with every API response
- 100-entry mock provider dataset generated using Google Antigravity (`providers.json`)

### Why the split?

**🔒 Security** — Isolates the Gemini API key, Google Maps API key, and orchestration logic from the client APK.

**🛠️ Maintainability** — Mobile UI developers and AI backend engineers can iterate independently.

**🚀 Deployment Flexibility** — The mobile app runs natively on Android; the orchestration engine runs on Vercel edge infrastructure with Next.js.

---

## 🔧 Edge Case Handling

The following edge cases are all implemented and visible in execution traces:

**Low-confidence or incomplete intent:** If the Intent Agent returns `isComplete: false` (missing service, location, or time), orchestration halts and returns a `clarificationPrompt` in the user's detected language. The conversation continues until all required fields are collected.

**No provider match:** If no providers match the service category, the system expands the search radius by 10km and drops the rating constraint, then falls back to the full non-rejected provider list. It flags `matchedExact: false` in the Gemini prompt, which adjusts the explanation to inform the user that an alternative has been recommended.

**Booking failure and retry:** The Booking Agent simulates a 10% provider unavailability rate. On failure, it automatically retries with the next ranked provider. The system attempts up to 3 providers before returning a graceful `status: "failed"` with a complete execution log.

**No providers in area:** If no results are returned even after relaxing constraints, the system halts with a "No providers in your area currently" message rather than a broken state.

**Network conditions:** The Orchestrator detects `2G`, `3G`, and `WiFi` conditions and applies adaptive modes — lite mode on 3G and text-only mode on 2G — logged as a `Bandwidth Adaptation` trace entry.

**Role-based access:** Provider accounts cannot submit customer service requests. The Orchestrator blocks this with a `Blocked` trace entry before the Intent Agent is invoked.

**Payment network timeout:** The Payment Layer simulates a 10% network timeout on escrow deposits with an automatic retry, mirroring real low-connectivity conditions in Pakistan.

**Mixed-service requests:** The Intent Agent extracts the primary service type based on NLP confidence weighting. Multi-service requests (e.g., "AC repair aur plumber") currently route to the highest-confidence service. An intent-splitter for parallel workflows is a planned future iteration.

**Score ties:** If two providers have identical scores, distance is the tiebreaker (closer wins).

---

## 📋 Assumptions & Limitations

**Provider Data:**
The backend uses a dataset of 100 mock providers covering Islamabad and Rawalpindi, generated using Google Antigravity (`providers.json`). Each record includes service category, real-area coordinates, rating, available time slots, base price, cost-per-km, and spoken languages. The Flutter app additionally uses a smaller hardcoded catalog in `provider_matcher_service.dart` for fast client-side matching. Real-world provider onboarding and live availability are outside the scope of this submission.

**Google Maps API:**
The backend attempts real Google Maps Geocoding and Distance Matrix API calls when `GOOGLE_MAPS_API_KEY` is set. If the key is absent or the call fails, the system falls back to a deterministic hash-based distance model (not random — results are stable across runs). User location in the `/api/chat` endpoint defaults to Islamabad centre coordinates when no precise location is provided.

**Booking Simulation:**
All bookings are fully simulated. No real provider is contacted. The booking ID and confirmation are mock data. The 90% success / 10% failure rate is modelled via a Gemini call to add realistic trace diversity.

**Payment:**
The escrow payment system (20% deposit via JazzCash) is entirely simulated in-memory. No real financial transaction occurs. Funds are stored in a `MOCK_TRANSACTIONS` in-memory map and released or refunded based on workflow events.

**Session Authentication:**
The Flutter app uses real Firebase Google Sign-In. The backend `/api/orchestrate` endpoint uses a mock in-memory session validator for the hackathon demo. Production deployment would integrate Firebase Admin token verification.

**Language Support:**
Urdu script input is supported via Gemini on the backend. The client-side `IntentParserService` handles Roman Urdu and English via keyword matching and edit-distance fuzzy logic but does not process Urdu script natively on-device.

**Notifications:**
Reminder and survey notifications are scheduled locally on-device via `flutter_local_notifications`. No real SMS or push notification infrastructure is connected in this submission.

**Mixed Services:**
Requests combining multiple services (e.g., "AC repair aur plumber") extract the primary service type based on NLP confidence. A multi-intent parallel workflow splitter is a planned future iteration.

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter (Dart) | Cross-platform mobile UI |
| **Authentication** | Firebase Auth | Google Sign-In |
| **Database** | Cloud Firestore | Chat sessions, service requests, user data |
| **File Storage** | Supabase | Profile image uploads |
| **AI Orchestration** | Next.js + Gemini 2.5 Flash | Multi-agent orchestration, NLP & booking reasoning |
| **Maps & Distance** | Google Maps Geocoding + Distance Matrix API | Real-world provider distance calculation |
| **Hosting** | Vercel | Backend API deployment |
| **Maps (Mobile)** | flutter_map + OpenStreetMap | Location picking |
| **Notifications** | flutter_local_notifications | Local push alerts |
| **Payment** | JazzCash (simulated escrow) | Deposit + release simulation |

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
│   ├── intent_parser_service.dart    # Client-side NLP intent extraction (Roman Urdu / English)
│   ├── provider_matcher_service.dart # Client-side provider ranking and matching
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
| **[KarigarAI](https://github.com/Mitul-Dial/KarigarAI)** | Next.js backend API + Gemini AI + Antigravity Orchestration | [Vercel](https://karigar-ai-nu.vercel.app) |

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
