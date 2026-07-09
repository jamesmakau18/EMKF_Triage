# Paramedic Triage Intake Application

This is a resilient, offline-first Flutter application designed for field paramedics operating in high-stress, time-critical environments where cellular network coverage is unstable or nonexistent.

## Architecture & Data Resilience

### Offline-First Resilience Engine
The core requirement is to ensure no data is lost when a paramedic submits a triage record while offline. The application architecture handles this as follows:

1. **Local Persistence (Hive)**: The UI never talks to a network directly. When a paramedic clicks "Submit", the `TriageRecord` is immediately saved to the local device storage using Hive. The save operation is fast, synchronized, and acts as the single source of truth.
2. **Background Sync Queue (`SyncService`)**: A dedicated background actor (`SyncService`) monitors device connectivity via `connectivity_plus`. 
   - When network connectivity is restored, it automatically flushes the local queue.
   - Concurrency guards (`_isFlushing` / `_flushRequested`) ensure only one flush operation happens at a time to prevent duplicate API calls.
   - Errors are handled per-record so a failure on one doesn't crash the entire background batch process.
3. **App Lifecycle Support**: The background sync will also attempt to flush when the app resumes from a suspended state (`AppLifecycleState.resumed`).

### State & Architecture Management (Riverpod)
The application strictly enforces a separation of concerns:
- **UI (Widgets)**: Only read/write data via Riverpod providers.
- **Providers**: Wire the UI to the `TriageRepository` and `SyncService`. They expose reactive state (e.g. `recordsProvider`, `pendingCountProvider`).
- **Repository (`TriageRepository`)**: The sole component managing Hive Box interactions.
- **Services (`HiveService`, `MockApiClient`, `SyncService`)**: Encapsulate external boundaries.

## Setup Instructions

1. Ensure you have Flutter installed.
2. Clone this repository.
3. Run `flutter pub get` to install dependencies.
4. Run tests with `flutter test`.
5. Run the application with `flutter run` on an iOS Simulator or Android Emulator.

## Walkthrough

- The main screen is optimized for fast thumb-input. 
- Priority levels 1 & 2 are visually distinct (Deep Red and Deep Orange respectively).
- Toggle Airplane mode and submit a record. You will see the record is saved and badges update correctly, avoiding any errors.
- Disable Airplane mode, and the `SyncService` will automatically push the pending records in the background.

### Simulating Network Failures & Delays
To prove the queue's resilience in unstable conditions:
- **Artificial Delay**: Every API request via `MockApiClient` has an artificial 2-second delay built in.
- **Random Failures**: You can toggle "Simulate Random Network Failures" on the Records List screen. When enabled, this introduces a 50% chance for an API request to fail, demonstrating that a failed record stays in the queue without crashing the app.
- **Manual Force Sync**: The AppBar on the Records List screen includes a manual "Force Sync" button so you can instantly re-trigger the queue processing when testing failed uploads.

## Demonstration

You can view the demonstration of the offline-first sync queue in action here:
[Screen Recording Demonstration](./Screen_recording_20260709_205632.webm)
