# Rule & Master Prompt: Production-Grade Flutter Base Architecture

> **Role & Directive for AI Assistants:** You are a Principal Flutter Architect. When scaffolding or maintaining this codebase, follow this specification strictly. Never take architectural shortcuts, never bypass layer boundaries, and never introduce conflicting DI or state management libraries.

---

## 🎯 Goal & Overview

Create a **production-grade Flutter starter project** that follows **Clean Architecture + MVVM**, **SOLID principles**, and strict architectural invariants — with type-safe networking (Dio), queued race-condition-safe token refresh, secure token storage, local caching, official localization (Bangla + English via intl/arb), responsive layout (ScreenUtil), and centralized theming.

This rule serves as both the architectural standard for AI coding agents and the master prompt for scaffolding new projects.

---

## 1. Core Architecture Principles

- **Clean Architecture with 3 Strict Layers**:
  - `presentation`: UI widgets, screens, and state holders only. Views observe reactive state and dispatch user events.
  - `domain`: Pure Dart business logic (Entities, Repository Interfaces, UseCases). **Zero dependencies on Flutter, Dio, GetX, or third-party serialization frameworks.**
  - `data`: Infrastructure implementations (DataSources, DTO Models with `@JsonSerializable`, Repository Implementations).
- **MVVM Pattern**:
  - View (`GetView<T>` or `GetWidget<T>`) → ViewModel (`GetxController`) → UseCase / Repository.
  - Views **never** reference repositories, data sources, or Dio directly.
  - Controllers **never** make direct HTTP calls or query storage directly.
- **SOLID Compliance**:
  - **Single Responsibility (S)**: ViewModel ≠ Repository ≠ DataSource. Each class has one reason to change.
  - **Open/Closed (O)**: Features extend via abstract repository contracts, never modifying core contracts.
  - **Liskov Substitution (L)**: Mock repositories (via `mocktail`) must be drop-in replacements for concrete implementations in all tests.
  - **Interface Segregation (I)**: Feature-specific abstract repositories (`AuthRepository`, `ProfileRepository`), never a monolithic `AppRepository`.
  - **Dependency Inversion (D)**: High-level modules (Controllers, UseCases) depend exclusively on abstract interfaces, injected via GetX Bindings (`Get.lazyPut`, `Get.find`). Strictly **NO `get_it` or `injectable`**.

---

## 2. Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # MaterialApp, theme, locale, routes
│   ├── bootstrap.dart              # runApp + DI + Hive/env init, error zone
│   └── flavors/                    # dev / staging / prod configs
│
├── core/
│   ├── constants/                  # app_constants.dart, api_endpoints.dart
│   ├── bindings/                   # initial_binding.dart (global lazyPut: Dio,
│   │                               #   storage services, core repos)
│   ├── error/                      # failures.dart, exceptions.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart      # attaches token, handles refresh
│   │   │   ├── logging_interceptor.dart
│   │   │   ├── error_interceptor.dart     # maps DioException → Failure
│   │   │   └── connectivity_interceptor.dart
│   │   └── network_info.dart              # connectivity_plus check
│   ├── storage/
│   │   ├── secure_storage_service.dart    # flutter_secure_storage (tokens)
│   │   └── local_cache_service.dart       # Hive/SharedPreferences (app data)
│   ├── routing/
│   │   ├── app_pages.dart                 # GetPage list (routes + bindings)
│   │   └── route_names.dart               # AppRoutes (static const paths)
│   ├── localization/
│   │   ├── app_localizations.dart
│   │   └── l10n/ (app_en.arb, app_bn.arb)
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_dimens.dart                # spacing/radius via .sp/.w/.h
│   │   ├── app_theme.dart                 # ThemeData light/dark
│   │   └── theme_provider.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── extensions/ (context_ext, string_ext, date_ext)
│   │   ├── logger.dart
│   │   └── result.dart                    # Either<Failure, T> (dartz/fpdart)
│   └── widgets/                           # shared buttons, loaders, dialogs
│
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── auth_remote_data_source.dart
│       │   │   └── auth_local_data_source.dart
│       │   ├── models/                    # DTOs — @JsonSerializable(), part
│       │   │                              #   'x_model.g.dart', extend Equatable
│       │   └── repositories/
│       │       └── auth_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/              # abstract AuthRepository
│       │   └── usecases/                  # LoginUseCase, LogoutUseCase
│       └── presentation/
│           ├── controllers/               # AuthController extends GetxController
│           ├── bindings/                  # AuthBinding (lazyPut controller + deps)
│           ├── screens/
│           └── widgets/
│
└── shared/
    └── models/                            # cross-feature entities (User, etc.)
```

Repeat the `features/<feature>/{data,domain,presentation}` pattern per feature
(profile, home, settings, etc.).

---

## 3. Networking (Dio)

- Single `DioClient` singleton, configured with `baseUrl`, timeouts, headers.
- **Interceptors (in order):**
  1. `AuthInterceptor` — injects `Authorization: Bearer <token>` from secure storage
     on every request; on `401`, pauses the queue, calls the refresh-token endpoint
     once, retries queued requests, and logs the user out if refresh fails
     (use `dio`'s `QueuedInterceptorsWrapper` to avoid race conditions on parallel
     401s).
  2. `LoggingInterceptor` — pretty request/response logs, disabled in release builds.
  3. `ConnectivityInterceptor` — short-circuits with a `NoInternetFailure` when offline.
  4. `ErrorInterceptor` — maps `DioException` (timeout, badResponse, cancel, etc.)
     into typed app `Failure` objects with readable messages.
- All API calls go through `RemoteDataSource` classes — never call `Dio` directly
  from a ViewModel or Repository.
- Wrap responses in a `Result<Failure, T>` (via `dartz` or `fpdart`) so ViewModels
  handle success/error without try/catch sprawl.

---

## 4. Token Handling & Caching

- Store `accessToken` / `refreshToken` in `flutter_secure_storage` — never in
  plain `SharedPreferences`.
- `TokenService` (or `AuthLocalDataSource`) exposes `getAccessToken()`,
  `saveTokens()`, `clearTokens()`, `getRefreshToken()`.
- Cache **non-sensitive** app/user data (last-viewed screen, cached profile,
  language, theme mode) in `Hive` or `SharedPreferences` for fast cold-start reads
  and offline-first UX.
- On refresh-token failure → clear tokens + cache → navigate to login (via a global
  `AuthStateNotifier`/stream the router listens to, not a hard `Navigator` call
  buried in an interceptor).

---

## 5. Repository Pattern

- `domain/repositories/*.dart` — abstract interfaces, pure Dart, no Flutter/Dio imports.
- `data/repositories/*_impl.dart` — implements the interface, decides
  remote vs local data source, converts DTO → Entity.
- ViewModels depend only on the abstract repository (or a UseCase wrapping it),
  injected through `get_it`. This keeps ViewModels unit-testable with mocked
  repositories (`mocktail`).

---

## 6. State Management — GetX

- Use **GetX** (`get` package) for state management, DI, and routing together —
  no need for `get_it`/`injectable`/`go_router` on top of it.
- Each screen/feature has one `Controller extends GetxController`:
  - Reactive state via `.obs` fields (`RxBool isLoading`, `Rxn<UserModel> user`,
    `Rx<ViewState> state`) — avoid overusing `GetBuilder` unless you specifically
    want non-reactive, manual `update()` control for performance-sensitive lists.
  - Model UI state as an enum/sealed-style class (`ViewState.idle/loading/success/
    error`) rather than scattering multiple loose booleans. If the state class
    carries data, extend **`Equatable`** and override `props` for value equality
    (instead of `freezed` unions) so GetX's reactivity/`Obx` rebuilds correctly
    only when the state actually changes.
  - Controllers call UseCases/Repositories — **never** call `Dio` or
    `GetConnect` directly from a Controller.
- Use **`Bindings`** (`AuthBinding`, `HomeBinding`) to lazily inject a screen's
  Controller + its dependencies only when that route is visited
  (`Get.lazyPut<AuthController>(() => AuthController(Get.find()))`), keeping
  memory usage low and avoiding a giant global `main.dart` DI file.
- Screens use `GetView<AuthController>` or `GetWidget<AuthController>` instead of
  `StatefulWidget` + manual controller wiring.

---

## 7. Models & Serialization — `json_serializable` (no hand-written JSON code)

- Every data-layer model (`UserModel`, `LoginResponseModel`, etc.) is annotated:

  ```dart
  import 'package:json_annotation/json_annotation.dart';
  import 'package:equatable/equatable.dart';

  part 'user_model.g.dart';

  @JsonSerializable()
  class UserModel extends Equatable {
    final String id;
    final String name;
    final String email;

    const UserModel({required this.id, required this.name, required this.email});

    factory UserModel.fromJson(Map<String, dynamic> json) =>
        _$UserModelFromJson(json);
    Map<String, dynamic> toJson() => _$UserModelToJson(this);

    @override
    List<Object?> get props => [id, name, email];
  }
  ```

- The `factory fromJson(...)` / `toJson()` method **signatures** are written by
  hand (one line each, calling the generated function) — the actual field-by-field
  parsing logic in `user_model.g.dart` is **always generated**, never hand-written
  or hand-edited.
- Generate/regenerate with:

  ```bash
  dart run build_runner build --delete-conflicting-outputs
  # during active development:
  dart run build_runner watch --delete-conflicting-outputs
  ```

- `.g.dart` files are committed to version control (standard for Flutter apps,
  since CI/CD and other devs shouldn't have to run codegen just to build).
- Domain-layer **entities** (plain, no JSON) also extend `Equatable` for value
  equality in UseCases/Controllers, even though they're never serialized directly.

---

## 8. Localization (Bangla + English)

- Use `flutter_localizations` + `intl` with `.arb` files (`app_en.arb`, `app_bn.arb`),
  generated via `flutter gen-l10n`.
- All user-facing strings go through `context.l10n.someKey` — no hardcoded strings
  in widgets.
- Persist selected locale in local cache; provide a `LocaleService`
  (`Get.updateLocale(Locale('bn', 'BD'))`) to switch language at runtime without
  restart.
- Alternative: skip `.arb`/`intl` entirely and use **GetX's built-in
  `Translations`** class (`Map<String, Map<String, String>>` keyed by locale,
  strings accessed via `'key'.tr`) — simpler for a small-to-mid app, but `.arb` +
  `intl` scales better for large string sets and designer/translator handoff.
  Pick one; don't mix both.
- Support Bangla numeral/date formatting where relevant (`intl` with `bn` locale,
  works fine alongside GetX regardless of which translation approach is chosen).

---

## 9. Theming / Colors / Font Sizes (centralized in `core/theme`)

- `AppColors` — static const colors + light/dark variants; no raw hex codes in widgets.
- `AppTextStyles` — named text styles (`heading1`, `bodyMedium`, `caption`, etc.)
  built on `google_fonts` or a bundled font family.
- `AppDimens`/spacing — use `flutter_screenutil` (`.sp`, `.w`, `.h`, `.r`) for
  responsive sizing across devices, defined once and reused everywhere.
- `AppTheme.light()` / `AppTheme.dark()` — full `ThemeData`, toggle via
  `ThemeProvider` persisted in cache.

---

## 10. Error Handling

- `core/error/failures.dart` — `Failure` classes extend **`Equatable`**
  (`ServerFailure`, `NetworkFailure`, `CacheFailure`, `AuthFailure`,
  `ValidationFailure`), each overriding `props` (typically `[message]`) so two
  failures with the same message compare equal in tests and state comparisons.
- `core/error/exceptions.dart` — low-level exceptions thrown by data sources,
  caught and converted to `Failure` in the Repository layer.
- A shared `ErrorMapper`/`ErrorHandler` widget or `SnackBar` utility standardizes
  how failures are shown to the user.

---

## 11. Dependency Injection — GetX Bindings

- No `get_it`/`injectable`. Use GetX's built-in service locator:
  - **`InitialBinding`** (set as `GetMaterialApp(initialBinding: ...)`) —
    `Get.put<DioClient>(DioClient(), permanent: true)`, plus storage services
    and any repository needed app-wide (e.g., `AuthRepository`, since the auth
    interceptor and route guards both need it).
  - **Per-feature `Bindings`** — `Get.lazyPut<X>()` for controllers/repositories
    only needed on that screen, auto-disposed when the route is popped
    (unless `fenix: true` is set for controllers you want recreated on demand).
- Repositories/UseCases are still coded against **abstract interfaces**; the
  concrete implementation is what gets bound in `Get.put`/`Get.lazyPut`, so
  swapping implementations (e.g., for tests) doesn't touch Controllers.

---

## 12. Routing — GetX

- `GetMaterialApp` + **named routes** via `app_pages.dart`
  (`List<GetPage>` with `binding:` set per route) — gives declarative
  navigation, nested routes, and transition animations without a separate
  router package.
- Route names centralized in `route_names.dart` as static consts
  (`AppRoutes.login`, `AppRoutes.home`) — no magic string paths in widgets.
- Navigate via `Get.toNamed(AppRoutes.home)`, `Get.offAllNamed(...)` (e.g., after
  logout) — no `BuildContext` required, so navigation works cleanly from
  Controllers/interceptors too.
- Auth-guarded routes: implement `GetMiddleware` (`onPageCalled`/`redirect`) that
  checks `AuthRepository`/token presence and redirects to login when needed,
  attached per-`GetPage` via `middlewares: [AuthMiddleware()]`.

---

## 13. Environment / Flavors

- `--dart-define` or `flutter_flavorizr` for `dev` / `staging` / `prod`, each with
  its own `baseUrl`, app icon/name, and Firebase config if used.
- `.env` (via `flutter_dotenv`) for non-secret runtime config; secrets never
  committed to source control.

---

## 14. Testing

- `test/` mirrors `lib/features/...` structure.
- Unit tests: Controllers (with mocked repositories via `mocktail`, using
  `Get.put()` to inject mocks before instantiating the controller under test),
  UseCases, Repositories (with mocked data sources).
- Widget tests for key screens; golden tests optional for design-system widgets.

---

## 15. Code Quality

- `analysis_options.yaml` with `very_good_analysis` or `flutter_lints` (strict mode).
- Enforce via CI: `flutter analyze`, `dart format --set-exit-if-changed`,
  `flutter test`.
- Pre-commit hook (e.g., `lefthook` or `husky`-style) running analyze + format.

---

## 16. Suggested Core Packages

| Purpose | Package |
|---|---|
| Networking | `dio` |
| State management, DI, routing | `get` (GetX) |
| Functional error handling | `fpdart` or `dartz` |
| Immutable models | `json_serializable` + `json_annotation` — models use `@JsonSerializable()` with generated `*.g.dart` for `fromJson`/`toJson`; never hand-write serialization code |
| Value equality | `equatable` — entities, `Failure` classes, and UI states extend `Equatable` and override `props`, instead of `freezed` unions |
| Secure token storage | `flutter_secure_storage` |
| Local cache | `hive`, `hive_flutter` (or `shared_preferences` for simple flags) |
| Responsive sizing | `flutter_screenutil` |
| Fonts | `google_fonts` |
| Localization | `intl`, `flutter_localizations` (or GetX's built-in `Translations` class — see note below) |
| Connectivity | `connectivity_plus` |
| Logging | `logger` |
| Env config | `flutter_dotenv` |
| Testing | `mocktail`, `flutter_test`, `get_test` (for testing GetX controllers/bindings) |
| Lints | `very_good_analysis` |

---

## 17. Deliverables Expected From the AI Assistant

1. Full folder structure scaffolded as above.
2. Working `DioClient` with all 4 interceptors, including a real refresh-token
   race-condition-safe implementation.
3. One complete vertical slice (e.g., **Auth: login/logout**) implemented
   end-to-end (data → domain → presentation, with `AuthController`,
   `AuthBinding`, and `GetPage` entry) as a reference pattern.
4. `core/theme`, `core/localization`, `core/storage`, `core/bindings` fully wired
   and working in `main.dart` via `GetMaterialApp`.
5. English + Bangla `.arb` files with at least the auth-flow strings, and a
   working language switcher.
6. `pubspec.yaml` with all packages above, pinned versions.
7. A short `README.md` explaining the architecture, folder structure, and how to
   add a new feature following the same pattern.
8. All models built with `json_serializable`/`equatable`, with generated
   `*.g.dart` files committed — no hand-written `fromJson`/`toJson` bodies
   anywhere in the codebase.
