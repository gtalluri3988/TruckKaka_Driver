# TruckKaka_Driver — Claude Instructions

> Canonical reference for AI-assisted development on this codebase.

---

## 1. Project Identity

| Field | Value |
|-------|-------|
| **App Name** | TruckKaka Driver |
| **Package Name** | `truck_kaka_driver` |
| **Android App ID** | `com.asva.truckkakadriver` |
| **Organization** | ASVA Technologies / ASVA Logistics |
| **Version** | 1.0.0+1 |
| **Dart SDK** | >=3.7.0 <4.0.0 |
| **Backend Base URL** | `https://www.asva.co.in/TransportApi/api/` |
| **Firebase Project** | `asva-3bb8c` |
| **Publish To** | `none` (private) |

**Product Summary:** TruckKaka Driver is the dedicated mobile app for drivers in the ASVA Logistics platform. It handles trip acceptance/rejection, trip lifecycle (start → pickup confirm → complete), advance requests, salary requests, and push notifications. It is a sibling app to TruckKaka_Mobile and shares the same backend API.

---

## Before Making Code Changes

- Always read all relevant markdown (`.md`) files before making any code changes.
- Follow project architecture, coding standards, and documented guidelines strictly.
- Do not introduce changes that conflict with existing documentation.
- If documentation is unclear, ask for clarification before proceeding.
- Use existing theme, design, fonts and styles — same as TruckKaka_Mobile.
- Use ONLY existing colors (`0xFF1B2A49`, `0xFF274472`) and typography (Poppins via `google_fonts`).
- Before modifying any screen, read existing screens to match the current design pattern.

---

## 2. Relationship to Other Projects

This app is part of the **Asva_Logistics monorepo**:

```
Asva_Logistics/
├── Asva_api/            # Backend REST API (.NET Core 7) — source of truth
├── asva-admin/          # Admin Panel (Angular)
├── TruckKaka_Mobile/    # Multi-role mobile app (Owner, Shipper, Driver)
└── TruckKaka_Driver/    # THIS APP — Driver-only mobile app (Flutter)
```

**Critical rule:** TruckKaka_Driver uses the **exact same API** as TruckKaka_Mobile. Never create new API endpoints without first checking `Asva_api/` controllers. Always read the API controller before building or modifying any feature.

---

## 3. Architecture & Design Pattern

**Pattern:** Hybrid MVC with GetX (same as TruckKaka_Mobile — NOT Clean Architecture, NOT BLoC).

Each feature module:
```
lib/modules/<feature>/
├── <feature>_screen.dart       # View (UI only, no business logic)
└── <feature>_controller.dart   # GetxController — calls Services directly
```

**Rules:**
- Controllers extend `GetxController` only — never `ChangeNotifier` or `Cubit`.
- Views use `Obx(() => ...)` or `GetBuilder<Controller>` for reactive rebuilds.
- No Repository layer — controllers call Services directly.
- No Use Cases — services map 1:1 to business domains.
- No Provider/Riverpod. Do not introduce other state management frameworks.

---

## 4. Project File Structure

```
TruckKaka_Driver/
├── lib/
│   ├── main.dart                              # Entry point — calls AppInit.initialize()
│   ├── firebase_options.dart                  # ⚠️ PLACEHOLDER — run flutterfire configure
│   ├── app/
│   │   ├── driver_app.dart                    # GetMaterialApp + OKToast wrapper
│   │   └── app_init.dart                      # Firebase + FCM + local notifications init
│   ├── api/
│   │   ├── api_url.dart                       # All endpoint path constants
│   │   └── api_service.dart                   # Dio + HTTP dual-client with JWT interceptor
│   ├── model/
│   │   ├── token_model.dart                   # Decoded JWT payload
│   │   ├── login_model.dart                   # OTP verify response
│   │   ├── trip_model.dart                    # TripModel + TripAdvanceModel + TripTransactionModel + NotificationModel
│   │   └── get_user_by_mobile_model.dart      # User flags (language, role, KYC)
│   ├── modules/
│   │   ├── splash/
│   │   │   └── splash_screen.dart             # Auth guard — routes to login or dashboard
│   │   ├── login/
│   │   │   ├── login_screen.dart              # Identical UI to TruckKaka_Mobile login
│   │   │   └── login_controller.dart          # Register phone → navigate to OTP
│   │   ├── otp/
│   │   │   ├── otp_screen.dart                # 6-digit PIN input
│   │   │   └── otp_controller.dart            # Verify OTP + driver gate checks
│   │   ├── language/
│   │   │   ├── language_screen.dart           # Language picker (4 locales)
│   │   │   └── language_controller.dart       # Saves locale + calls UpdateUserLanguage API
│   │   ├── main_screen/
│   │   │   ├── main_screen.dart               # Shell with bottom nav
│   │   │   └── main_controller.dart           # Tab index management
│   │   ├── home/
│   │   │   ├── home_screen.dart               # Dashboard: active trip banner + quick action grid
│   │   │   └── home_controller.dart           # Checks active trip on load, shows accept/reject popup
│   │   ├── trips/
│   │   │   ├── assigned_trips/
│   │   │   │   ├── assigned_trips_screen.dart # List of active/pending trips
│   │   │   │   └── assigned_trips_controller.dart
│   │   │   ├── trip_history/
│   │   │   │   ├── trip_history_screen.dart   # Completed + cancelled trips
│   │   │   │   └── trip_history_controller.dart
│   │   │   └── trip_detail/
│   │   │       ├── trip_detail_screen.dart    # Full trip info + action buttons
│   │   │       └── trip_detail_controller.dart # Start, Confirm Pickup, Complete, Request Advance
│   │   ├── advance/
│   │   │   ├── advance_screen.dart            # Request form + history list
│   │   │   └── advance_controller.dart        # Submit to Trip/SaveAdvanceRequest
│   │   ├── salary/
│   │   │   ├── salary_screen.dart             # Salary breakdown card + status banner
│   │   │   └── salary_controller.dart         # Loads GetAllTripTransactionHistory
│   │   ├── account/
│   │   │   ├── account_screen.dart            # Profile header + menu links + logout
│   │   │   └── account_controller.dart
│   │   └── payments/
│   │       ├── payments_screen.dart           # Summary cards + completed trips list
│   │       └── payments_controller.dart
│   ├── routes/
│   │   └── app_routes.dart                    # All GetPage definitions + route constants
│   ├── services/
│   │   ├── auth_service.dart                  # register(), verifyOtp(), getUserByMobile()
│   │   ├── trip_service.dart                  # All trip CRUD, advance, salary, tracking
│   │   └── notification_service.dart          # getNotifications(), markAsRead()
│   └── utils/
│       ├── common_widgets/
│       │   └── common_button.dart             # Reusable button (loading state aware)
│       ├── dialogue_service/
│       │   └── dialogues.dart                 # warningToast, successToast, confirmDialog
│       ├── local_storage/
│       │   ├── stored_data.dart               # SharedPreferences wrapper
│       │   └── stored_keys.dart               # All storage key constants
│       └── localization/
│           ├── app_translation.dart           # Registers all locale maps
│           ├── translation_keys.dart          # Key constants (TrKeys.*)
│           └── language_json/
│               ├── en_us.dart
│               ├── hi_in.dart
│               └── te_in.dart
├── android/
│   ├── app/
│   │   ├── build.gradle                       # compileSdk 36, applicationId, multidex
│   │   └── src/main/
│   │       ├── AndroidManifest.xml            # Permissions, activity, FCM service
│   │       └── kotlin/.../MainActivity.kt
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradle.properties
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 5. State Management

**Framework:** GetX v4.7.3

```dart
// Reactive variable declaration
RxBool isLoading = false.obs;
RxString driverName = ''.obs;
RxList<TripModel> trips = <TripModel>[].obs;
Rxn<TripModel> activeTrip = Rxn<TripModel>();   // nullable

// Mutation (always use .value =)
isLoading.value = true;
trips.value = fetchedList;

// Manual rebuild
update();

// Controller registration
Get.put(HomeController());          // eager
Get.find<HomeController>();         // lookup
```

**Lifecycle hooks:**
- `onInit()` — read route arguments, sync setup
- `onReady()` — async data fetch after widget mounted
- `onClose()` — dispose controllers, cancel timers

---

## 6. Navigation & Routing

All routes defined in `lib/routes/app_routes.dart`.

| Constant | Path | Screen |
|---|---|---|
| `AppRoute.splash` | `/` | SplashScreen |
| `AppRoute.login` | `/login` | LoginScreen |
| `AppRoute.otp` | `/otp` | OtpScreen |
| `AppRoute.language` | `/language` | LanguageScreen |
| `AppRoute.dashboard` | `/dashboard` | MainScreen |
| `AppRoute.assignedTrips` | `/assigned-trips` | AssignedTripsScreen |
| `AppRoute.tripHistory` | `/trip-history` | TripHistoryScreen |
| `AppRoute.tripDetail` | `/trip-detail` | TripDetailScreen |
| `AppRoute.advance` | `/advance` | AdvanceScreen |
| `AppRoute.salary` | `/salary` | SalaryScreen |

**Navigation helpers:**
```dart
Get.toNamed(AppRoute.tripDetail, arguments: {'tripId': 123})
Get.offAllNamed(AppRoute.dashboard)
Get.back()
```

**Route arguments pattern:**
```dart
// Sender
Get.toNamed(AppRoute.tripDetail, arguments: {'tripId': trip.tripId});

// Receiver (in controller onInit)
final args = Get.arguments as Map<String, dynamic>?;
tripId = args?['tripId'] as int? ?? 0;
```

---

## 7. HTTP & API Layer

**Dual client strategy (do not collapse into one):**

| Client | Used For |
|---|---|
| `Dio` | Primary — all authenticated requests, interceptors, multipart |
| `IOClient (http)` | Fallback — login/OTP (no auth header needed), SSL bypass |

**ApiService interface:**
```dart
ApiService.post(url, data)               // Dio POST with JWT
ApiService.postWithFormData(url, data)   // Dio multipart
ApiService.get(url, queryParameters)     // Dio GET with JWT
ApiService.ioPost(url, data)             // HTTP POST (no auth, for login/OTP)
ApiService.ioGet(url)                    // HTTP GET (no auth)
ApiService.isNetworkAvailable()
```

**Error handling convention:**
- Non-200 responses return an empty `Response` — they do NOT throw.
- Controllers must check `response.statusCode == 200` manually.
- Dio exceptions are caught in try-catch blocks inside controllers/services.

**Must call `ApiService.init()` before first use** — done in `SplashScreen.initState()`.

---

## 8. Authentication Flow

```
Phone Number Entry
    └─ POST Register/RegisterUser {mobile, fcmToken}
           └─ Navigate to OTP screen

OTP Verification
    └─ POST Auth/VerifyOtp {mobile, otp}
           ├─ HTTP 403 → "Not assigned to any owner" error (driver gate)
           ├─ HTTP 200 → LoginModel (JWT + roles + menus)
           │      ├─ StoredData.saveToken(token)
           │      ├─ StoredData.saveTokenAsModel(token)   # decode JWT
           │      ├─ StoredData.saveLoginModel(data)
           │      └─ getUserByMobile() → check isLanguageSelected
           └─ Route: language not set → /language, else → /dashboard

Subsequent Requests
    └─ Dio interceptor auto-injects Authorization: Bearer <token>

Splash Guard
    └─ StoredData.isAuthenticated() → /dashboard or /login
```

**Driver-specific gate (enforced by backend):**
- HTTP 403 on `/Auth/VerifyOtp` → driver not assigned to any owner → show error, block login.
- HTTP 400 on `Trip/UpdateTripStatusByDriver` with status=Accepted → driver has no license uploaded → show KYC error.

---

## 9. Local Storage

**Package:** `shared_preferences: 2.5.3`

**Wrapper:** `lib/utils/local_storage/stored_data.dart`

```dart
StoredData.saveToken(token)
StoredData.getToken()                    // → String?
StoredData.isAuthenticated()             // → bool (checks JWT expiry)
StoredData.saveTokenAsModel(token)       // decode JWT + save as TokenModel
StoredData.getTokenModel()               // → TokenModel?
StoredData.saveLoginModel(model)
StoredData.saveUserByMobile(model)
StoredData.setLanguage(language: 'en')
StoredData.getLanguage()
StoredData.applyStoredLocale()           // call on splash to restore locale
StoredData.clearAll()                    // call on logout
```

**Storage keys:** Always use `StorageKeys.*` constants from `stored_keys.dart` — never hardcode strings.

---

## 10. Driver Dashboard & Bottom Nav

**Bottom Navigation (3 tabs):**
| Tab | Icon | Screen |
|---|---|---|
| Home | home_rounded | HomeScreen |
| Account | person_rounded | AccountScreen |
| Payments | account_balance_wallet_rounded | PaymentsScreen |

**Dashboard Quick Action Menu (4 cards):**
| Card | Route |
|---|---|
| Assigned Trips | `/assigned-trips` |
| Trip History | `/trip-history` |
| Advance Requests | `/advance` |
| Salary Requests | `/salary` |

---

## 11. Trip Lifecycle

```
Owner assigns driver
    └─ FCM push notification sent to driver
    └─ API: Trip.Status → PendingDriverAcceptance

Dashboard load (HomeController.onReady)
    └─ GET Trip/GetActiveAssignedTrip
           └─ if hasActiveTrip && isPendingAcceptance → show Accept/Reject popup

Driver ACCEPTS
    └─ POST Trip/DriverResponse {tripId, accept: true}
           └─ Trip.Status → Accepted
           └─ GPS tracking consent confirmed
           └─ Navigate to TripDetailScreen

Driver REJECTS
    └─ POST Trip/DriverResponse {tripId, accept: false}
           └─ Trip.Status → Planned (reset, driver removed)

Driver taps START TRIP
    └─ GET Trip/UpdateTripStatusByDriver?tripId=X&status=2
           └─ Trip.Status → OnGoing
           └─ GPS tracking active

Driver taps CONFIRM PICKUP
    └─ POST Trip/ConfirmPickup {tripId}
           └─ Trip.Status → PickupConfirmed
           └─ ⚠️ Cancellation LOCKED after this point

Driver taps COMPLETE TRIP
    └─ Camera opens → capture delivery proof
    └─ POST Trip/SaveTripImages (multipart, imageType="unloading")
    └─ GET Trip/UpdateTripStatusByDriver?tripId=X&status=4
           └─ Trip.Status → Completed
           └─ Navigate to SalaryScreen
```

**Trip status values (numeric) used in UpdateTripStatusByDriver:**
| Value | Meaning |
|---|---|
| 2 | Started / OnGoing |
| 4 | Completed |

---

## 12. Advance Request Flow

```
Driver opens Advance screen (with tripId argument)
    └─ Loads existing advances: GET Trip/gettripAdvanceDetailsByTripId?tripId=X
    └─ Driver fills: Amount, Reason, Payment Mode (UPI/Cash/Bank Transfer)
    └─ POST Trip/SaveAdvanceRequest {tripId, requestedAmount, requestorComments, paymentMode}
           └─ Owner receives FCM notification
           └─ List reloads showing new request with status "Pending"
```

**Advance approval statuses displayed:**
- `Pending` → orange chip
- `Approved` → green chip (shows approved amount)
- `Rejected` → red chip

---

## 13. Salary Request Flow

```
Trip Completed → Navigate to SalaryScreen with {tripId}
    └─ GET Trip/GetAllTripTransactionHistory?tripId=X
           └─ Shows: EarnedSalary, ApprovedAmount, AfterAdjustment, Balance
    └─ GET Trip/GetCurrentStatusForSalary?tripId=X
           └─ -1 = not yet requested
           └─  0 = pending approval
           └─  1 = approved
           └─  2 = rejected

Driver taps REQUEST SALARY
    └─ Confirm dialog shown
    └─ Owner receives notification via existing trip completion flow
    └─ Owner approves/rejects via admin panel or TruckKaka_Mobile
```

---

## 14. Push Notifications (FCM)

**Handled in:** `lib/app/app_init.dart`

Events driver receives:
| Event | Trigger |
|---|---|
| Trip Assigned | Owner assigns driver to trip |
| Advance Approved | Owner approves advance request |
| Advance Rejected | Owner rejects advance request |
| Salary Approved | Owner approves salary |
| Salary Rejected | Owner rejects salary |

**Implementation:**
- Foreground: `flutter_local_notifications` shows heads-up notification
- Background: `_firebaseMessagingBackgroundHandler` (top-level function, `@pragma('vm:entry-point')`)
- Channel ID: `truckkaka_driver_channel`

---

## 15. Localization

**Supported Locales:** `en_US`, `hi_IN`, `te_IN`

**Files:**
```
lib/utils/localization/
├── app_translation.dart       # Registered in GetMaterialApp.translationsKeys
├── translation_keys.dart      # TrKeys.* constants
└── language_json/
    ├── en_us.dart
    ├── hi_in.dart
    └── te_in.dart
```

**Usage:**
```dart
Text(TrKeys.assignedTrips.tr)    // .tr extension from GetX
```

**Switch locale:**
```dart
Get.updateLocale(const Locale('hi', 'IN'));
StoredData.setLanguage(language: 'hi');
```

**Adding a new key:**
1. Add constant to `translation_keys.dart`
2. Add translation in all 3 locale files
3. Use `TrKeys.yourKey.tr` in widgets — never hardcode visible strings

---

## 16. UI / Design System

**Colors (hardcoded — no ThemeData color references):**
```dart
const Color primaryDark = Color(0xFF1B2A49);   // appbar, buttons, headers
const Color primaryMid  = Color(0xFF274472);   // gradient end, accents
const Color bgLight     = Color(0xFFF4F6FB);   // scaffold background
const Color bgCard      = Color(0xFFF8FAFF);   // input fill, cards
```

**Typography:** Google Fonts Poppins (via `google_fonts` package)
```dart
GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)
```

**Gradient (login, appbar, headers):**
```dart
LinearGradient(
  colors: [Color(0xFF1B2A49), Color(0xFF274472)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

**Buttons:** Use `CommonButton` from `lib/utils/common_widgets/common_button.dart`
- Supports: `isLoading`, `prefixIcon`, `suffixIcon`, `needBorder`, `color`, `textColor`
- Height: 50px, borderRadius: 14px, font: Poppins w600

**Cards:** White background, `borderRadius: 16`, subtle shadow:
```dart
BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
```

**Status chips:** Colored container with 20px borderRadius (green=approved, orange=pending, red=rejected)

---

## 17. UI Rules

1. All API calls go in `services/` files only — never call API directly from screens.
2. Models in `model/` must match API response field names exactly — read the API controller before creating or updating any model.
3. Every screen must handle 3 states: **Loading**, **Success**, **Error**.
4. NEVER override or break existing theme — same colors, same fonts, same spacing as TruckKaka_Mobile.
5. Buttons MUST be state-aware:
   - Default → normal clickable
   - Loading → `CircularProgressIndicator` inside button, disabled
   - Success → feedback + navigate/update
   - Error → error message shown, button re-enabled for retry
   - No double-tap: disable on first tap until response
6. Status-based UI: screens showing trip/advance/salary status must read from API and conditionally render — do not show action buttons for completed/cancelled states.
7. Before building or modifying any screen, read existing screens to match card style, button style, spacing, layout.

---

## 18. API-Frontend Contract Checklist

Verify for every API interaction:

| Check | API (Asva_api) | Driver App |
|---|---|---|
| Endpoint URL | Route definition | `ApiUrl.*` constant |
| HTTP Method | GET/POST | Must match |
| Auth Header | Middleware | Dio interceptor handles |
| Request Body | Controller expects | Payload sent |
| Response Shape | Controller returns | Model parses |
| Error Codes | Error responses | Controller checks `statusCode` |
| Field Names | Model field names | Must use same names |

---

## 19. Key API Endpoints Used

| Feature | Method | Endpoint |
|---|---|---|
| Register phone | POST | `Register/RegisterUser` |
| Verify OTP | POST | `Auth/VerifyOtp` |
| Save FCM token | POST | `Auth/SaveFCM` |
| Get user by mobile | GET | `User/GetUserDetailsByMobile` |
| Update language | POST | `Register/UpdateUserLanguage` |
| Get all trips | GET | `Trip/GetAllTrips` |
| Get trip by ID | GET | `Trip/GetTripsDetailesById?tripId=` |
| Get active assigned trip | GET | `Trip/GetActiveAssignedTrip` |
| Accept/reject trip | POST | `Trip/DriverResponse` |
| Update trip status | GET | `Trip/UpdateTripStatusByDriver?tripId=&status=` |
| Confirm pickup | POST | `Trip/ConfirmPickup` |
| Upload trip images | POST | `Trip/SaveTripImages` (multipart) |
| Save advance request | POST | `Trip/SaveAdvanceRequest` |
| Get advances by trip | GET | `Trip/gettripAdvanceDetailsByTripId?tripId=` |
| Get trip transactions | GET | `Trip/GetAllTripTransactionHistory?tripId=` |
| Get salary status | GET | `Trip/GetCurrentStatusForSalary?tripId=` |
| Get notifications | GET | `Notification/GetUserNotifications` |
| Mark notification read | POST | `Notification/MarkAsRead` |

---

## 20. Before First Run — Setup Steps

```bash
# 1. Generate missing platform scaffolding (ios/, res/, gradle wrapper, etc.)
cd TruckKaka_Driver
flutter create --project-name truck_kaka_driver --org com.asva .

# 2. Configure Firebase — generates real lib/firebase_options.dart
flutterfire configure --project=asva-3bb8c

# 3. Download google-services.json for package com.asva.truckkakadriver
#    Firebase Console → Project Settings → Android → Add App
#    Place at: android/app/google-services.json

# 4. Install dependencies
flutter pub get

# 5. Run on device
flutter run
```

---

## 21. Adding a New Feature

**Step 1:** Read API → `Asva_api/` controllers + models
**Step 2:** Add endpoint to `lib/api/api_url.dart`
**Step 3:** Add service method to relevant service in `lib/services/`
**Step 4:** Add/update model in `lib/model/` — fields must match API exactly
**Step 5:** Create controller in `lib/modules/<feature>/<feature>_controller.dart`
**Step 6:** Create screen in `lib/modules/<feature>/<feature>_screen.dart`
**Step 7:** Add route to `lib/routes/app_routes.dart`
**Step 8:** Add localization keys to `translation_keys.dart` and all 3 locale files

---

## 22. Dependency Summary

| Category | Packages |
|---|---|
| State / DI / Routing | `get: 4.7.3` |
| HTTP | `dio: 5.4.0`, `http: 1.2.0` |
| Firebase | `firebase_core: 3.6.0`, `firebase_messaging: 15.1.3` |
| Auth / JWT | `jwt_decoder: 2.0.1` |
| Storage | `shared_preferences: 2.5.3` |
| UI / Fonts | `google_fonts: 6.2.0`, `pinput: 6.0.1`, `lottie: 3.1.2`, `shimmer: 3.0.0`, `iconsax: 0.0.8` |
| Notifications | `flutter_local_notifications: 17.2.4` |
| File / Image | `image_picker: 1.0.7`, `file_picker: 10.3.7` |
| Network | `connectivity_plus: 7.0.0` |
| Utilities | `oktoast: 3.4.0`, `permission_handler: 12.0.1`, `url_launcher: 6.3.0`, `intl: 0.20.2` |

---

## 23. Quick Commands

```bash
# Install dependencies
flutter pub get

# Run on Android (dev)
flutter run

# Build APK (release)
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Analyze code
flutter analyze
```

---

## 24. Important Conventions

1. **Always use `.value =`** to mutate Rx variables.
2. **Controllers registered via `BindingsBuilder()` in routes** — do not use `Get.put()` inside widget trees.
3. **HTTP error handling:** check `response.statusCode == 200` — non-200 does not throw.
4. **Route navigation:** always use `AppRoute.*` constants — never hardcode path strings.
5. **Token storage:** always go through `StoredData.*` — never read/write SharedPreferences keys directly.
6. **API endpoints:** always declare in `lib/api/api_url.dart` — never hardcode URLs in controllers or services.
7. **Localization keys:** always declare in `translation_keys.dart` and use `.tr` extension — never hardcode visible strings in widgets.
8. **Images/files:** use `image_picker` — always ask for camera permission via `permission_handler` first.
9. **`ApiService.init()` must be called** before any API call — it is called in `SplashScreen.initState()`.
10. **`firebase_options.dart` is a placeholder** — the app will not build for Firebase until `flutterfire configure` is run.
