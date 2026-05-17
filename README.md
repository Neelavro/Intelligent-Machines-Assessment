# SiteLog

**SiteLog** is a Flutter mobile application that combines GPS-based attendance marking with on-site visual capture. Field workers can mark their attendance only when physically within range of the registered office location, and capture batches of photos that are automatically synced to a remote server — even when connectivity is intermittent.

---

## Features

- **GPS Attendance** — Mark attendance only when within 50m of the registered office location, with live distance tracking
- **Custom Camera** — Pinch-to-zoom, tap-to-focus, vertical zoom slider, and zoom pill shortcuts (0.5x / 1x / 2x)
- **Batch Photo Capture** — Queue multiple photos and upload them as a single batch
- **Offline-First Sync** — Images are persisted locally in Hive and synced automatically when connectivity is restored
- **Background Sync** — WorkManager schedules periodic background uploads even when the app is closed
- **Permission Handling** — Graceful permanently-denied states for both camera and location, with a direct link to device settings

---

## User Guide

### First-Time Setup

1. **Grant permissions** — On first launch the app requests location and camera access. Both are required. If you tap *Don't Allow*, the app shows a full-screen prompt; tap **OPEN SETTINGS** to re-enable the permission in your device settings.

2. **Set your office location** — Open the **Attendance** screen (the home screen). Stand at — or be physically near — the office, then tap **Set Office Location**. The app saves your current GPS coordinates as the registered office position. You only need to do this once.

---

### Marking Attendance

1. Go to the **Attendance** screen.
2. Watch the **distance badge** below the office card — it updates live as you move.
   - Green badge = you are within 50 m of the office.
   - Red badge = you are outside the 50 m radius.
3. Once the badge turns green and the lock icon disappears, tap **Mark Attendance**.
4. A success or error toast confirms the result.

> The attendance window is **09:00 AM – 10:30 AM**. The button is disabled outside this window.

---

### Opening the Camera

Tap the **camera icon in the top-right corner** of the Attendance screen's app bar to open the **Camera Preview** screen.

---

### Capturing Photos

| Control | Where | Action |
|---|---|---|
| **Shutter button** | Bottom-centre (large white circle) | Tap to capture a photo |
| **Zoom pills** | Bottom row above shutter | Tap 0.5×, 1×, or 2× for quick zoom presets |
| **Zoom slider** | Right edge | Drag up/down for fine-grained zoom control |
| **Pinch gesture** | Camera preview area | Pinch in or out to zoom |
| **Tap to focus** | Camera preview area | Tap anywhere to auto-focus; a crosshair indicator appears for 2 seconds |

Each captured photo is added to the local queue and counted on the **batch thumbnail** in the bottom-left corner.

---

### Uploading a Batch

1. After capturing your photos, tap **UPLOAD BATCH (N)** at the bottom of the Camera Preview screen. This queues all captured images for upload.
2. If you are online, the sync starts immediately.
3. If you are **offline**, a red banner — **"NO CONNECTION — IMAGES QUEUED"** — appears at the top of the camera screen. The upload will start automatically once connectivity is restored.

---

### Viewing Upload Status

Tap the **photo library icon in the top-right corner** of the Camera Preview screen (or the batch thumbnail in the bottom-left) to open the **Upload Manager**.

The Upload Manager shows:

- A progress bar with bytes uploaded vs. total
- A live **STABLE LINK / NO CONNECTION** status pill (top-right of the screen)
- Per-image status cards:
  - **UPLOADING…** — actively transferring
  - **WAITING FOR CONNECTION** — queued, no network
  - **RETRYING… (ATTEMPT X/5)** — transient failure, auto-retrying
  - **SYNCED** — successfully uploaded
  - **FAILED — MAX RETRIES REACHED** — upload failed after 5 attempts

Tap **START NEW UPLOAD BATCH** at the bottom to return to the camera and begin a new batch.

---

### Navigation at a Glance

```
Attendance Screen  ──[camera icon, top-right]──▶  Camera Preview Screen
                                                        │
                        [photo library icon, top-right] │
                        [batch thumbnail, bottom-left]  │
                                                        ▼
                                                   Upload Manager
                                                        │
                              [back arrow, top-left] ◀──┘
```

---

## Project Structure

```
lib/
├── core/                         # App-wide services
│   ├── location_service.dart     # Geolocator wrapper
│   ├── network_info.dart         # Connectivity check
│   ├── sync_engine.dart          # Foreground + background sync orchestrator
│   └── app_toast.dart
│
├── domain/                       # Business logic — no Flutter/platform imports
│   ├── entities/
│   │   ├── location_entity.dart
│   │   └── upload_item_entity.dart
│   ├── repository/
│   │   ├── attendance_repository.dart
│   │   └── camera_repository.dart
│   └── usecases/
│       ├── attendance_usecase.dart
│       └── camera_usecase.dart
│
├── data/                         # Data layer — implements domain contracts
│   ├── datasource/
│   │   ├── attendance_datasource.dart
│   │   ├── attendance_local_datasource.dart
│   │   ├── camera_local_datasource.dart   # Hive-backed upload queue
│   │   └── camera_remote_datasource.dart  # Mock remote API
│   ├── model/
│   │   ├── upload_item_model.dart
│   │   └── upload_item_model_adapter.dart # Manual Hive TypeAdapter
│   └── repository/
│       ├── attendance_repository_impl.dart
│       └── camera_repository_impl.dart
│
├── presentation/
│   ├── attendance/
│   │   ├── bloc/                 # AttendanceBloc, events, states
│   │   ├── screen/               # AttendanceScreen
│   │   └── widgets/              # OfficeLocationCard, DistanceBadge, MarkAttendanceButton
│   └── camera/
│       ├── bloc/                 # CameraBloc, events, states
│       ├── screen/               # CameraPreviewScreen, UploadManagerScreen
│       └── widgets/              # ShutterButton, ZoomPillRow, VerticalZoomSlider,
│                                 # FocusIndicator, BatchThumbnail, CircleIconButton,
│                                 # UploadCard, BatchSyncProgress, StatusPill
│
├── injection_container.dart      # GetIt dependency injection
└── main.dart                     # Entry point, Hive init, WorkManager bootstrap
```

---

## Architectural Approach

SiteLog follows **Clean Architecture** with a strict three-layer separation: **Domain → Data → Presentation**.

- The **Domain layer** defines pure Dart entities, abstract repository contracts, and use cases — no Flutter or platform dependencies
- The **Data layer** implements those contracts using Hive for local persistence and a mock remote datasource for uploads
- The **Presentation layer** uses the **BLoC pattern** exclusively via `flutter_bloc`

### BLoC Classes

| BLoC | Responsibility |
|---|---|
| `AttendanceBloc` | Manages location permission, streams live GPS position via `LocationService`, computes distance to the registered office, and handles attendance submission through `AttendanceUsecase` |
| `CameraBloc` | Manages `CameraController` lifecycle, zoom, tap-to-focus, photo capture, batch queueing to Hive, upload triggering, and real-time connectivity state via `SyncEngine` |

Both BLoCs are provided at the **app root** via `MultiBlocProvider` in `main.dart` so their state survives screen navigation.

---

## Generative AI Usage

Claude (Anthropic) was used throughout this project as a pair-programming assistant — not to generate the entire codebase in one shot, but to build and iterate feature by feature with active review and direction.

### How it was used

- Scaffolding the clean architecture skeleton and wiring up dependency injection in `injection_container.dart`
- Writing BLoC boilerplate across `camera_bloc.dart` and `attendance_bloc.dart` (events, states, handler methods)
- Implementing the Hive persistence layer, WorkManager background tasks, and the `SyncEngine`
- Debugging runtime crashes using actual device error logs

---

### Key Prompts That Shaped the Project

---

> **"Follow the exact same project structure that already exists — don't introduce new patterns or reorganize anything."**

Set the architectural constraint from the very start. Prevented any drift into different patterns or unnecessary abstractions beyond what the existing attendance feature already established.

---

> **"All widgets should go into the `widgets/` directory — not inline inside the screen file."**

Enforced the widget extraction pattern the existing codebase already followed. This was applied consistently across all 9 camera widgets: `ShutterButton`, `ZoomPillRow`, `VerticalZoomSlider`, `FocusIndicator`, `BatchThumbnail`, `CircleIconButton`, `UploadCard`, `BatchSyncProgress`, and `StatusPill` — all in `lib/presentation/camera/widgets/`.

---

> **"`syncPendingUploads()` in `CameraRepositoryImpl` is never actually calling `cameraRemoteDatasource.uploadImage()` — it's only reading and updating the local Hive queue. The remote datasource is injected into the repository but nothing in the foreground sync path is ever using it. The images are not being sent anywhere."**

Caught that `CameraRemoteDatasource` was registered in `injection_container.dart` and wired into `CameraRepositoryImpl`, but `syncPendingUploads()` was silently iterating the queue, updating statuses, and never making a single remote call. The foreground upload path was completely hollow.

---

> **"When permission is permanently denied, `AttendanceBloc._onInitialLoad` is still emitting `AttendanceLoaded` and `CameraBloc._onInitialized` is still emitting `CameraLoading` before the permission check even runs — so the loading UI flashes on screen before the denied state appears. The `isPermanentlyDenied` check needs to be the very first thing in both handlers, emit the `PermissionDenied` state right there and return — nothing else should run after that. Add `_buildPermissionDenied()` to both `attendance_screen.dart` and `camera_preview_screen.dart` with an OPEN SETTINGS button."**

Caught a sequencing bug where the loading state was visible before the permission gate. Fixing it required restructuring both `_onInitialLoad` and `_onInitialized` so the `isPermanentlyDenied` guard sits at the top with an early return, making it impossible for any loading or loaded state to emit first.

---

> **"Navigating away from `CameraPreviewScreen` is crashing with `ImageReader` buffer overflow because the controller is still streaming frames — calling `dispose()` directly doesn't stop the pipeline. In `CameraBloc._onDispose`, emit `CameraInitial` first so the `CameraPreview` widget unmounts and stops consuming frames, then null out `_controller`, then call `pausePreview()`, and only then call `dispose()` on the saved controller reference."**

Identified that the crash wasn't from the disposal itself but from the frame pipeline still being active when the buffer tried to write. The fix required a strict ordering in `camera_bloc.dart`: state change → null the field → pause the stream → dispose the controller.

---

> **"Calling `context.read<CameraBloc>()` inside `dispose()` is crashing because the widget is already deactivated and the context has no valid ancestor at that point. Store the BLoC in `initState()` as a `late final CameraBloc _bloc = context.read<CameraBloc>()` and use that field in `dispose()` directly — don't go through context there."**

Caught that the crash in `camera_preview_screen.dart` was a widget lifecycle issue, not a BLoC issue. Context is only safe while the widget is mounted — `dispose()` is called after unmount, so any `context.read()` there is undefined behavior. Storing the reference in `initState()` sidesteps the context entirely.

---

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc ^9.1.1` | BLoC state management |
| `get_it ^9.2.1` | Dependency injection |
| `dartz ^0.10.1` | Functional error handling (`Either`) |
| `geolocator ^13.0.0` | GPS position and distance calculation |
| `camera ^0.11.1` | Camera controller and live preview |
| `hive_flutter ^1.1.0` | Local upload queue persistence |
| `workmanager ^0.9.0+3` | Background periodic sync |
| `connectivity_plus ^6.0.0` | Network connectivity stream |
| `permission_handler ^11.4.0` | Runtime permission requests |
| `fluttertoast ^9.0.0` | Success/error toast messages |
| `equatable ^2.0.8` | Value equality for BLoC states |

---

## How to Run

### Prerequisites

- Flutter SDK `>=3.9.2`
- Xcode (for iOS) or Android Studio / Android SDK (for Android)
- A **physical device** is strongly recommended — the camera and GPS do not work reliably on simulators or emulators

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/your-username/sitelog.git
cd sitelog

# 2. Install dependencies
flutter pub get

# 3. Run the app on a connected device
flutter run
```

### Android Notes

The following permissions are declared in `android/app/src/main/AndroidManifest.xml`:
- `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`
- `CAMERA`
- `INTERNET`
- `RECEIVE_BOOT_COMPLETED`, `WAKE_LOCK` (required by WorkManager)

### iOS Notes

The following usage descriptions are declared in `ios/Runner/Info.plist`:
- `NSLocationWhenInUseUsageDescription`
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- Background modes: `fetch`, `processing`

---

## Screenshots

> Replace the placeholders below with screenshots or a screen recording of the app.

| Attendance Screen | Camera Screen | Upload Manager |
|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

| Permission Denied — Location | Permission Denied — Camera | No Connection Banner |
|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

---

## Known Issues

- **Not optimised for all screen sizes** — UI layouts are built with fixed paddings and sizes and have not been tested or adapted for tablets or unusually small phone screens. Some widgets may overflow or appear cramped on non-standard viewports.

- **Distance updates are gated at 3 metres** — The position stream in `LocationService.getPositionStream()` uses `distanceFilter: 3`, meaning the device only emits a new position after physically moving 3 metres. The distance badge and the in-range check will not reflect movement smaller than that threshold, so a user standing just outside the 50m boundary may not see the UI update until they cross the next 3m gate.

- **Ultra-wide (0.5×) not supported on Android** — The 0.5× zoom pill is intentionally disabled on all Android devices. The Flutter `camera` package does not expose sub-1× zoom levels, and devices like the Pixel 8 and Nothing Phone each expose their ultra-wide sensor in a different, device-specific way (logical multi-camera zoom ratio vs. separate physical camera ID). A reliable, device-agnostic implementation requires either the `camerax` pub package or direct Camera2 API work; this is tracked as a future improvement. The 1× and 2× pills and pinch-to-zoom remain fully functional.
