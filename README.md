# V-Fridge mobile

Flutter client for the [v-fridge-api](https://github.com/ynshvrh/v-fridge-api) backend. Same JSON API the [Next.js SPA](https://github.com/ynshvrh/V-Fridge) consumes — JWT bearer, no cookies.

## Targets

| Platform | Status |
| --- | --- |
| Android | Primary — Android SDK 35 |
| iOS | Configured, needs a Mac to build / sign |
| Web | Builds (`flutter build web`); secure-storage falls back to localStorage on the JS target |

## Features

- Sign in + sign up (with email-verification waiting screen)
- Token refresh: single-flight on 401, tokens in Android Keystore / iOS Keychain via `flutter_secure_storage`
- Dashboard: list products in the active fridge, add via bottom sheet, freshness chip, "mark finished" → consumption log
- Shopping list: add / check off / delete / "purchase → move to fridge"
- Meal planner: generate 5-day plan, one-tap import gap items into the shopping list
- AI chef chat: conversation with persistence, 5/60 s rate limit handled
- Settings: profile + fridges management (rename, create, invite, delete / leave, pick active via `X-Fridge-Id`) + sign out

## Run

```bash
flutter pub get

# Android emulator → host machine's API on localhost:5080 is reached via 10.0.2.2.
flutter run -d emulator-5554

# Real device or production API:
flutter run --dart-define=API_URL=https://v-fridge-api.onrender.com

# Web (Chrome):
flutter run -d chrome --dart-define=API_URL=https://v-fridge-api.onrender.com
```

## Architecture

```
lib/
├── main.dart                 # MaterialApp + auth-driven routing
├── models/
│   └── api_models.dart       # Hand-rolled DTOs mirroring src/VFridge.Api/Contracts/* (no codegen)
├── api/
│   ├── api_client.dart       # Dio + secure-storage tokens + single-flight refresh + X-Fridge-Id header
│   └── services.dart         # Per-endpoint-group service classes
├── providers/
│   └── providers.dart        # Riverpod providers + AuthController state machine
└── screens/
    ├── auth/                 # signin, signup
    ├── dashboard/            # products list + add sheet
    ├── chat/                 # AI chef
    ├── shopping/             # shopping list
    ├── planner/              # weekly meal plan
    ├── settings/             # profile + fridges + sign out
    └── home_shell.dart       # bottom NavigationBar that hosts the five tabs
```

- **State:** Riverpod. `AuthController` is the single source of truth for `{loading, authenticated, unauthenticated}` and the current user. The root widget switches between splash / signin / home shell based on it.
- **HTTP:** Dio with an `Interceptor` that injects the bearer, single-flights `POST /auth/refresh` on 401, retries the original request, and falls back to clearing tokens on a refresh failure.
- **Storage:** `flutter_secure_storage` for the access + refresh token and the picked `X-Fridge-Id`.
- **DTOs:** Hand-rolled records / classes per the OpenAPI doc at `https://v-fridge-api.onrender.com/openapi/v1.json`. Kept in sync manually; small enough that codegen adds more friction than value.

## Out of scope (for now)

- Barcode scanner (Phase 4 on web; will need camera + native plugin on mobile)
- Analytics dashboard (Phase 3.1)
- Google sign-in (the API endpoint is ready; the GSI integration on mobile uses `google_sign_in` plugin which needs platform config)
- Push notifications

## Why no OpenAPI codegen?

`openapi-generator-cli`/`swagger_dart_code_generator` work, but generated clients add a few hundred lines of boilerplate and a coupling to a specific tool. The API surface is small (~25 endpoints, ~10 DTOs), so hand-rolling is faster to evolve.
