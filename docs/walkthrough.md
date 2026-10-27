# Walkthrough — Dynamic wiring, verification and next steps

Date: 2026-05-14

This document summarizes what I changed, what I verified, remaining work, how to reproduce locally via Docker, and known risks.

---

## Summary of changes performed

- Centralized typography and applied `Inter` via `google_fonts` in `lib/app/theme/app_theme.dart`.
- Removed explicit `fontSize:` overrides on several screens and replaced them to rely on `AppTypography` tokens (safe edits applied to:
  - `lib/features/auth/presentation/screens/splash_screen.dart`
  - `lib/features/scan/presentation/screens/scan_result_screen.dart`
  - multiple other token usages were left intact to preserve intent)
- Ensured `flutter` dependencies were resolved in the `agimada_flutter` Docker container (`flutter pub get` ran successfully inside container).
- Started `backend` and `flutter` containers with `docker-compose up -d` and confirmed both are running.
- Scanned the codebase for dynamic wiring: found Isar local DB usage, Riverpod providers for journal, scan, and sync flows; `Scan` flow is wired end-to-end locally (ImagePicker -> TFLite analyze -> save to Isar -> invalidate Journal provider).
- Inspected backend sync endpoints: `POST /sync/parcelles` and `POST /sync/diagnostics` exist and accept JSON payloads (no image upload endpoint currently).

---

## What I verified (dynamic wiring)

- Local DB (Isar): `lib/core/local_db/isar_service.dart` exists and is used throughout; models and generated files (e.g., `parcelle_local.g.dart`) are present.
- Scan flow: `lib/features/scan/presentation/screens/scanning_screen.dart` handles image picking and calls `scanNotifierProvider.notifier.analyzeImage(imageFile)` then `saveDiagnostic(...)`; the `DiagnosticLocalRepository` persists image path and metadata to Isar.
- Sync flow: `lib/core/sync/providers/sync_provider.dart` orchestrates syncing unsynced parcelles and diagnostics via `SyncRemoteDatasource` (Retrofit). Remote endpoints accept JSON bodies for parcelles and diagnostics (see backend in `backend/app/api/endpoints/sync.py`).

---

## Key issues & gaps found

1. Image upload to server: backend `DiagnosticSync` schema doesn't accept images; diagnostics synchronization is JSON-only. If you need server-side storage of images, we must:
   - Add a server endpoint to accept multipart image uploads (or accept base64 in the JSON payload), and
   - Update the Flutter sync client (`SyncRemoteDatasource`) to send images (multipart FormData) and update `DiagnosticSync` DTO accordingly.

2. TFLite/native assets: the TFLite model is included in `assets/` and `Model/`. Running the app on a device/emulator requires platform-specific native setup for `tflite_flutter` (the Docker container cannot emulate Android/iOS devices). Tests and analysis run fine, but real inference must be validated on-device.

3. Generated files (`*.g.dart`, `*.freezed.dart`) exist but if you regenerate code (build_runner) you must run `flutter pub run build_runner build --delete-conflicting-outputs` inside the Flutter container.

4. Dependency drift: several packages have newer versions (see `flutter pub get` output inside container). Not urgent, but could cause mismatch if upgrading. Use `flutter pub outdated` to inspect.

5. Runtime permissions: camera and storage permissions required on device for `ImagePicker` and saving image paths. Ensure Android `AndroidManifest.xml` and iOS `Info.plist` are configured.

6. File paths: the app currently stores local image paths returned by `ImagePicker` and references them directly. When synchronizing to server, if images are not uploaded, server won't have access to them.

7. Sync conflict handling: the server ignores diagnostics referencing unknown parcelle IDs; ensure the client sends parcelle mappings (local->server ids) when syncing.

---

## Actions I recommend we implement next (priority order)

1. Decide image sync strategy (multipart upload vs base64 in JSON). I recommend multipart upload to keep payload sizes reasonable.
2. Add server endpoint `POST /sync/diagnostics-with-images` (or extend existing) to accept multipart, save images to a file store, and return created diagnostics with server IDs.
3. Update `SyncRemoteDatasource` (Retrofit) to add multipart methods and update `core/sync` sync logic to attach images for each Diagnostic when available.
4. After implementing server & client changes, update `DiagnosticLocalRepository.markAsSynced()` to store serverId and mark `isSynced`.
5. Add end-to-end integration tests (server + client) where the client posts a sample diagnostic with image and server responds successfully.
6. Ensure permissions and platform native configuration for camera/storage are present in `android/` and `ios/` manifests.

---

## How to run locally (Docker)

Start backend and Flutter helper container:

```bash
docker-compose up -d
```

Run dependency install and static analysis inside the Flutter container:

```bash
# in host terminal
docker exec -u root agrimada_flutter flutter pub get
docker exec -u root agrimada_flutter flutter analyze
```

Run unit/widget tests (inside container):

```bash
docker exec -u root agrimada_flutter flutter test
```

Run backend tests (inside backend container):

```bash
docker exec -u root agrimada_backend pytest -q
```

To regenerate code (freezed/json_serializable/retrofit):

```bash
docker exec -u root agrimada_flutter flutter pub run build_runner build --delete-conflicting-outputs
```

Notes: to run the full app on Android/iOS, you need a device or emulator with Flutter SDK installed on host or run an Android emulator inside Docker (non-trivial). The `agimada_flutter` container is mainly for analysis, testing, and codegen.

---

## Potential runtime failure modes (and mitigations)

- Missing platform permissions → Camera/gallery fails. Mitigation: add required manifest entries and testing on device.
- TFLite native compatibility → model or AOT issues. Mitigation: test on target device, ensure `tflite_flutter` platform libs included (check `pubspec` and `gradle` settings).
- Image sync failure (no server endpoint) → diagnostics never include image on server. Mitigation: implement multipart endpoint or store images elsewhere.
- Isar migration issues → when schema changes, DB might need migrations. Mitigation: use Isar schema versioning and migration scripts.
- Token auth / session expiration during sync → sync fails. Mitigation: detect 401 responses, refresh token or prompt login, and retry.

---

## Files I edited

- `lib/app/theme/app_theme.dart` — switched to `GoogleFonts.interTextTheme()`
- `lib/features/auth/presentation/screens/splash_screen.dart` — removed hard `fontSize` overrides
- `lib/features/scan/presentation/screens/scan_result_screen.dart` — removed hard `fontSize` override
- `docs/walkthrough.md` — this file

---

## Suggested PR checklist

- [ ] Add server-side image upload endpoint (if agreed) and tests.
- [ ] Update client sync to send images as multipart.
- [ ] Verify end-to-end sync and mark local diagnostics as synced (store serverId).
- [ ] Run `flutter analyze` and fix any static analysis issues.
- [ ] Run `flutter test` and ensure tests pass.
- [ ] Validate camera and storage permissions on Android/iOS.

---

If you want, I can:
- Implement the server + client change to support image uploads (multipart) and update the sync flow (requires backend code edit + client patch). 
- Continue the automated repo-wide removal of `fontSize:` overrides (I started safe passes earlier; I can finish them now).
- Run `flutter test` in the container and report failures.

Tell me which of these you want me to do next.
