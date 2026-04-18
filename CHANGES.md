# TruckKaka Driver — Changes Log

---

## 2026-04-16 — Feature: Mobile-based Background GPS Tracking System

Production-grade background location tracking that survives app kill, handles offline storage, and syncs batched GPS data to the API.

### New Packages

| Package | Version | Purpose |
|---------|---------|---------|
| `geolocator` | ^14.0.0 | GPS with accuracy, speed, heading, mock detection |
| `flutter_background_service` | ^5.0.12 | Android foreground service (survives app kill) |
| `flutter_background_service_android` | ^6.2.7 | Android-specific foreground service types |
| `sqflite` | ^2.4.1 | SQLite offline queue for GPS points |

### New Files

| Timestamp | File | Action | Requirement |
|-----------|------|--------|-------------|
| 2026-04-16 | `lib/model/location_model.dart` | Created LocationPoint (with SQLite row mapping), BulkUploadResponse, TrackingConfig models | Data models for offline queue, API upload, and server-configurable thresholds |
| 2026-04-16 | `lib/services/location_service.dart` | Created GPS wrapper: permission check/request, GPS enabled check, stream-based tracking with smart intervals (speed > 2 m/s = 15s, else 120s), accuracy filter (>50m rejected), distance filter (<10m ignored), mock location detection via geolocator's `isMocked` | Core GPS engine with all filtering logic — configurable thresholds from server |
| 2026-04-16 | `lib/services/location_queue_service.dart` | Created SQLite-backed offline queue: `location_queue` table with indexed `synced` column. Methods: enqueue(), getUnsyncedBatch(limit), markSynced(ids), cleanup(>24h), pendingCount() | GPS points must survive network outages — SharedPreferences unreliable for structured batch data at volume |
| 2026-04-16 | `lib/services/location_sync_service.dart` | Created HTTP batch upload service: POST /api/Tracking/BulkUpload with array of LocationPoints. Returns updated config. Also fetchConfig() for initial load | Dequeues pending points, uploads, marks synced. Server response includes updated config parameters |
| 2026-04-16 | `lib/services/background_tracking_service.dart` | Created foreground service orchestrator using flutter_background_service. `@pragma('vm:entry-point')` isolate entry. Persistent notification "TruckKaka - Trip tracking active". GPS stream -> enqueue to SQLite -> periodic sync every 30s. Handles start/stop commands from main isolate | Must survive app minimization, recents clearing, and device sleep. Foreground service is the only reliable approach on Android 10+ |

### Modified Files

| Timestamp | File | Action | Requirement |
|-----------|------|--------|-------------|
| 2026-04-16 | `pubspec.yaml` | Added geolocator, flutter_background_service, flutter_background_service_android, sqflite | New tracking dependencies |
| 2026-04-16 | `android/app/src/main/AndroidManifest.xml` | Added FOREGROUND_SERVICE, FOREGROUND_SERVICE_LOCATION, WAKE_LOCK permissions. Added BackgroundService declaration with `foregroundServiceType="location"` | Android requires explicit foreground service declaration for background GPS |
| 2026-04-16 | `lib/api/api_url.dart` | Added `trackingBulkUpload` and `trackingConfig` endpoint constants | API URL contract for tracking endpoints |
| 2026-04-16 | `lib/utils/local_storage/stored_keys.dart` | Added trackingTripId, trackingDriverId, trackingEnabled, trackingConfig keys | Background service isolate reads persisted trip/driver IDs |
| 2026-04-16 | `lib/app/app_init.dart` | Added `BackgroundTrackingService.initialize()` in AppInit.initialize() | Background service must be configured before first use |
| 2026-04-16 | `lib/modules/trips/trip_detail/trip_detail_controller.dart` | In `startTrip()`: added `BackgroundTrackingService.startTracking(tripId, driverId)` after successful status update. In `completeTrip()`: added `BackgroundTrackingService.stopTracking()` before status update | Tracking starts when driver starts trip, stops when driver completes trip |
| 2026-04-16 | `lib/modules/home/home_controller.dart` | In `_checkActiveTrip()`: if active ongoing trip exists and tracking not running, resume via `BackgroundTrackingService.startTracking()` | Tracking must auto-resume after app restart if trip is still active |
| 2026-04-16 | `lib/utils/localization/translation_keys.dart` | Added 7 tracking keys: trackingActive, trackingStarted, trackingStopped, gpsDisabled, enableGps, locationPermissionRequired, backgroundLocationRequired | Localization support for tracking UI messages |
| 2026-04-16 | `lib/utils/localization/language_json/en_us.dart` | Added English translations for 7 tracking keys | English locale |
| 2026-04-16 | `lib/utils/localization/language_json/hi_in.dart` | Added Hindi translations for 7 tracking keys | Hindi locale |
| 2026-04-16 | `lib/utils/localization/language_json/te_in.dart` | Added Telugu translations for 7 tracking keys | Telugu locale |

---

## 2026-04-15 — Fix: Advance request history not displaying + Trip Detail enhancements

**Root Cause:** `getAdvancesByTrip()` in `trip_service.dart` tried `res.data['result']` on a bare array response from the API — caused silent TypeError, returned empty list.

| Timestamp | File | Action | Requirement |
|-----------|------|--------|-------------|
| 2026-04-15 | `lib/services/trip_service.dart` — `getAdvancesByTrip()` | Fixed response parsing to handle both `{result: [...]}` (wrapped) and `[...]` (bare array) formats | API returned bare array but service expected wrapped — silent TypeError returned empty list |
| 2026-04-15 | `lib/modules/trips/trip_detail/trip_detail_controller.dart` | Added `advances` RxList, `isLoadingAdvances`, `loadAdvances()` method; `requestAdvance()` now awaits navigation and refreshes on return | Trip detail screen had no advance data; no refresh after submitting advance request |
| 2026-04-15 | `lib/modules/trips/trip_detail/trip_detail_screen.dart` | Added advance history section with `_AdvanceRow` widget (reused pattern from `trip_history_detail_screen.dart`); shows loading/empty/list states | Advance history was only visible on separate Advance screen, not on Trip Detail |

---

## 1. Firebase Configuration Fix
**File:** `lib/firebase_options.dart`

**Problem:** App was hanging on the splash screen because `firebase_options.dart` contained placeholder values (`REPLACE_WITH_ANDROID_API_KEY`, etc.). `Firebase.initializeApp()` is called with `await` in `main()` before `runApp()`, so the hang blocked the entire app.

**Fix:** Replaced placeholder values with real credentials sourced from `android/app/google-services.json`.

| Field | Value |
|---|---|
| `apiKey` | `AIzaSyCjYJgVUS4svmrHvYUcBuI0G5hrFBOoIBI` |
| `appId` | `1:374485808141:android:abb06022933a36710a9144` |
| `messagingSenderId` | `374485808141` |
| `projectId` | `asva-3bb8c` |
| `storageBucket` | `asva-3bb8c.firebasestorage.app` |

---

## 2. Splash Screen — Redesigned to Match TruckKaka_Mobile
**File:** `lib/modules/splash/splash_screen.dart`

**Problem:** Splash screen used a generic truck icon (`Icons.local_shipping_rounded`) and did not match the TruckKaka_Mobile app design.

**Changes:**
- Replaced truck icon with `ASVAlogo.png` inside a `CircleAvatar(radius: 80)`
- Added `Hero(tag: 'asva_logo')` so the logo animates into the login screen
- Changed animation curve from `Curves.easeIn` (900ms) to `Curves.easeInOut` (2s) — matches Mobile
- Updated app name to `'ASVA Technologies'` — same font, size, weight as Mobile
- Subtitle set to `'Driver App'` with matching style (`white70`, `fontSize 14`, `letterSpacing 0.3`)
- Progress indicator updated: `Colors.white70`, `strokeWidth: 2.5` — matches Mobile
- Added `mounted` guard before navigation to prevent setState-after-dispose

**Asset added:** `assets/images/dashboard/ASVAlogo.png` — copied from `TruckKaka_Mobile/assets/images/dashboard/`.

---

## 3. Login Screen — Logo Replaced
**File:** `lib/modules/login/login_screen.dart`

**Problem:** Login screen showed a truck icon instead of the ASVA logo, and used a different Hero tag (`'driver_logo'`) that broke the Hero animation from splash.

**Changes:**
- Replaced `Icons.local_shipping_rounded` icon with `Image.asset('assets/images/dashboard/ASVAlogo.png')` inside a `CircleAvatar(radius: 60)`
- Changed Hero tag from `'driver_logo'` to `'asva_logo'` — now matches splash screen tag so the logo Hero-animates correctly between screens
- Added owner-access error banner (see Change 5 below)

---

## 4. Driver Owner-Assignment Gate — API
**File:** `Asva_api/Asva_api/Controllers/AuthController.cs`

**Problem:** No pre-login check existed to verify that a driver was added by an owner before sending an OTP. The previous 403 check inside `VerifyOTP` was unreliable because it depended on role detection which could silently fail.

**Business Rule:**
- Owner adds a driver via TruckKaka_Mobile → creates a `User` record + `Driver` record with `OwnerId` set
- A driver who was never added by an owner must be blocked from logging in
- Check happens **before OTP is sent** — no SMS wasted on an unregistered driver

**New Endpoint:** `GET Auth/CheckDriverAccess?mobile=xxx`

```
Logic (UserRepository.CheckDriverHasOwnerAsync):
  1. Find user in Users table WHERE Mobile = mobile
     → not found → 403
  2. Find record in Drivers table WHERE UserId = user.Id AND OwnerId != 0
     → no Driver record → 403 (owner never added this driver)
     → OwnerId = 0     → 403 (added but not assigned to owner)
     → OwnerId > 0     → 200 OK
```

- `[AllowAnonymous]` — called before login, no JWT available
- Uses existing `_userService.CheckDriverHasOwnerAsync()` — no new DB logic needed
- Returns `403 { message: "You are not assigned to any owner. Contact admin." }` on failure
- Returns `200 { isAllowed: true }` on success

---

## 5. Driver Owner-Assignment Gate — Flutter Login
**Files:**
- `lib/api/api_url.dart`
- `lib/services/auth_service.dart`
- `lib/modules/login/login_controller.dart`
- `lib/modules/login/login_screen.dart`

### `api_url.dart`
Added URL constant:
```dart
static String checkDriverAccess = 'Auth/CheckDriverAccess';
```

### `auth_service.dart`
Added pre-login check method:
```dart
Future<bool> checkDriverAccess(String mobile) async {
  // GET Auth/CheckDriverAccess?mobile=xxx (no auth header)
  // Returns true if 200, false if 403 or error
}
```
Uses `ApiService.ioGet` (no JWT) since the driver is not logged in yet.

### `login_controller.dart`
**Full rewrite of `login()` method.** New flow:

```
1. Validate mobile format
2. Call CheckDriverAccess → if false → set accessError, stop (no OTP sent)
3. Call RegisterUser (send OTP)
4. Navigate to OTP screen on success
```

Added reactive state:
```dart
RxString accessError = ''.obs;  // shown as banner on login screen
```

Also fixed: `ApiService.post` (Dio, requires init) was incorrectly used for `RegisterUser` — changed to `ApiService.ioPost` (HTTP fallback, no auth needed for unauthenticated registration).

### `login_screen.dart`
Added a reactive error banner between the logo/title and the phone input field:
- Shown when `controller.accessError.value.isNotEmpty`
- Red border, `Icons.block_rounded`, full error message
- Clears automatically on next login attempt

---

## 6. Driver Owner-Assignment Gate — Flutter OTP (Safety Net)
**Files:**
- `lib/modules/otp/otp_controller.dart`
- `lib/modules/otp/otp_screen.dart`

Secondary check kept at OTP verification as a safety net (in case `CheckDriverAccess` is bypassed).

### `otp_controller.dart`
- Added `RxBool isNotAssigned = false.obs`
- Reset to `false` at start of every `verifyOtp()` call
- On HTTP 403 from `VerifyOTP`: `isNotAssigned.value = true` (previously showed only a dismissable toast)
- Removed stale comment referencing unimplemented 403 handling

### `otp_screen.dart`
Added a prominent error banner shown when `isNotAssigned == true`:
- Appears above the Verify button
- Same visual style as login screen banner (red border, block icon, message)
- Distinct from `otpError` (which turns PIN cells red for wrong OTP)
- Disappears on the next verification attempt

---

## Summary of Files Changed

| File | Project | Change |
|---|---|---|
| `lib/firebase_options.dart` | Driver | Real Firebase credentials |
| `lib/modules/splash/splash_screen.dart` | Driver | ASVA logo, Hero, matching design |
| `lib/modules/login/login_screen.dart` | Driver | ASVA logo, Hero tag fix, error banner |
| `lib/modules/login/login_controller.dart` | Driver | Owner check before OTP, error state |
| `lib/modules/otp/otp_controller.dart` | Driver | `isNotAssigned` flag, 403 handling |
| `lib/modules/otp/otp_screen.dart` | Driver | Owner error banner |
| `lib/api/api_url.dart` | Driver | `checkDriverAccess` URL constant |
| `lib/services/auth_service.dart` | Driver | `checkDriverAccess()` method |
| `assets/images/dashboard/ASVAlogo.png` | Driver | Copied from TruckKaka_Mobile |
| `Asva_api/Controllers/AuthController.cs` | API | `CheckDriverAccess` endpoint |
