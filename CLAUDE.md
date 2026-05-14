# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app
flutter run

# Run on a specific device
flutter run -d <device-id>

# Build APK
flutter build apk

# Analyze (lint)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Get dependencies
flutter pub get
```

## Environment Setup

Copy `.env.example` to `.env` and fill in the values:

```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
```

The `.env` file is bundled as an asset (listed in `pubspec.yaml`) and loaded at startup via `flutter_dotenv`.

## Architecture

**State management**: `provider` package with `ChangeNotifier`. Providers are registered at the root in `main.dart` via `MultiProvider`.

**Feature-based folder structure** under `lib/features/<feature>/`:
- `screens/` — full-page widgets
- `providers/` — `ChangeNotifier` state classes consumed via `Consumer`/`context.read`
- `services/` — data-fetching logic (when feature-local)
- `widgets/` — reusable sub-widgets for that feature

**Core layer** (`lib/core/`):
- `api/api_client.dart` — singleton HTTP client wrapping `package:http`. Base URL is hardcoded to `http://127.0.0.1:8000`. All endpoints are defined in `api/api_endpoints.dart` under `/api/v1`.
- `api/api_interceptor.dart` — (interceptor helpers)
- `models/` — plain Dart models with `fromJson`/`toJson`. `Property` is the central model with rich computed helpers (`formattedPrice`, `priceWithPeriod`, `bestImage`, `typeColor`, etc.)
- `services/` — cross-feature services: `AuthService`, `PaymentService`, `PropertyService`, `ChatService`, `InspectionService`, `UserService`
- `storage/secure_storage.dart` — wraps `flutter_secure_storage` to persist the JWT token and serialized user JSON between sessions

**Shared** (`lib/shared/`):
- `themes/` — app theme
- `widgets/` — common widgets (`PropertyNetworkImage`, `LoadingIndicator`, `CustomAppBar`, `AppErrorWidget`)

**Two backends in use**:
1. Custom REST API (via `ApiClient`) — used for all property, auth, favorites, inspections, payments
2. Supabase (`supabase_flutter`) — initialized in `main.dart`; used alongside the custom API (e.g., for storage/realtime in chat)

## Navigation

`MainScaffold` (defined in `main.dart`) hosts a `BottomNavigationBar` with five tabs: Home, Search, Post, Chats, Profile. Deep-link routes are handled via `onGenerateRoute`:
- `/property-detail` — expects `String` argument (property ID)
- `/login`
- `/register`

## Key Patterns

**Auth flow**: `SecureStorage` holds the JWT. `AuthService.getCurrentUser()` validates the token against the `/api/v1/auth/me` endpoint; on 401/403 the token is cleared. Screens check `ProfileProvider` for the current user and show `AuthenticatedProfile` vs `GuestProfile` accordingly.

**API calls**: Services call `ApiClient` methods (`get`, `post`, `put`, `delete`, `postMultipart`). Pass `requiresAuth: true` to attach the Bearer token. Errors surface as `ApiException` with a `statusCode`.

**Payment**: Paystack integration via `flutter_paystack`. The flow is: initiate payment (backend returns a `TransactionModel` with `paystackReference`) → Paystack checkout UI → verify payment via backend. Funds are held in escrow for 72 hours. The Paystack public key is currently hardcoded in `payment_screen.dart:28` — move it to `.env` before production.

**Property posting**: Multi-step form in `PostPropertyScreen` using a `PageController`. Steps cover basic info, location (Nigeria state/LGA via `nigeria_lg_state_city`), pricing/details, images (`image_picker`), and video links (YouTube/Vimeo supported).
