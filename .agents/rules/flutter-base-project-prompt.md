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
  - `domain`: Pure Dart business logic (Entities, Repository Interfaces, UseCases). **Zero dependencies on Flutter, Dio, GetX, or third-party frameworks (pure Dart only; equatable and fpdart permitted).**
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
  - **Dependency Inversion (D)**: High-level modules (Controllers, UseCases) depend exclusively on abstract interfaces, injected via GetX Bindings (`Get.lazyPut`, `Get.find`).

---

## 2. Canonical Folder Structure

```
lib/
├── main.dart                       # App entrypoint, runs bootstrap & initializes environment
├── app/
│   ├── app.dart                    # GetMaterialApp, ScreenUtilInit, theme, locale, routes
│   ├── bootstrap.dart              # Async init: Hive, SecureStorage, global error zones
│   └── flavors/                    # dev / staging / prod flavor configurations
│
├── core/
│   ├── bindings/                   # initial_binding.dart (permanent singletons: DioClient, storage)
│   ├── constants/                  # app_constants.dart, api_endpoints.dart
│   ├── error/                      # failures.dart (Equatable), exceptions.dart
│   ├── localization/               # app_localizations.dart, l10n/ (app_en.arb, app_bn.arb)
│   ├── network/
│   │   ├── dio_client.dart         # Singleton Dio wrapper with base configuration
│   │   ├── network_info.dart       # connectivity_plus checker interface & impl
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart          # QueuedInterceptorsWrapper token refresh
│   │       ├── logging_interceptor.dart       # Pretty log in debug mode only
│   │       ├── error_interceptor.dart         # Maps DioException → typed Failure
│   │       └── connectivity_interceptor.dart  # Short-circuits when offline
│   ├── routing/
│   │   ├── app_pages.dart          # List<GetPage> with routes, bindings, and middlewares
│   │   └── route_names.dart        # Static const route paths (AppRoutes)
│   ├── storage/
│   │   ├── secure_storage_service.dart        # flutter_secure_storage (tokens only)
│   │   └── local_cache_service.dart           # hive_flutter (user preferences/cache)
│   ├── theme/
│   │   ├── app_colors.dart         # Semantic color tokens (light/dark)
│   │   ├── app_dimens.dart         # Responsive dimensions, paddings, radii (.w, .h, .r)
│   │   ├── app_text_styles.dart    # Standardized typography hierarchy (.sp)
│   │   └── app_theme.dart          # ThemeData for light and dark modes
│   ├── utils/
│   │   ├── extensions/             # context_ext.dart, string_ext.dart
│   │   ├── logger.dart             # logger package wrapper
│   │   └── validators.dart         # Form and input validation helpers
│   └── widgets/                    # Reusable atomic UI (AppButton, AppTextField, AppLoader)
│
├── features/
│   └── auth/                       # Reference feature vertical slice
│       ├── data/
│       │   ├── datasources/        # auth_remote_data_source.dart, auth_local_data_source.dart
│       │   ├── models/             # auth_response_model.dart (@JsonSerializable + Equatable)
│       │   └── repositories/       # auth_repository_impl.dart
│       ├── domain/
│       │   ├── entities/           # user_entity.dart (Pure Dart + Equatable)
│       │   ├── repositories/       # auth_repository.dart (Abstract interface)
│       │   └── usecases/           # login_usecase.dart, logout_usecase.dart
│       └── presentation/
│           ├── bindings/           # auth_binding.dart (Get.lazyPut dependencies)
│           ├── controllers/        # auth_controller.dart (GetxController with ViewState)
│           ├── screens/            # login_screen.dart (GetView<AuthController>)
│           └── widgets/            # Feature-specific widgets (login_form.dart, etc.)
│
└── shared/
    └── models/                     # Cross-feature shared entities & DTOs
```

### Essential Root Configuration Files
In addition to `lib/`, the starter project mandates these root files:
- **`l10n.yaml`**: Root configuration for Flutter's official localization generator:
  ```yaml
  arb-dir: lib/core/localization/l10n
  template-arb-file: app_en.arb
  output-localization-file: app_localizations.dart
  untranslated-messages-file: untranslated_messages.json
  ```
- **`analysis_options.yaml`**: Strict linter rules extending `very_good_analysis` or `flutter_lints` with strict-raw-types, strict-inference, and strict-casts enabled.
- **`assets/`**: Structured asset directory containing `icons/`, `images/`, and `fonts/`.

Repeat the `features/<feature>/{data,domain,presentation}` pattern for all subsequent features (profile, settings, etc.).

---

## 3. Networking Architecture (Dio)

### 3.1 DioClient Specification
- Single `DioClient` registered as a permanent singleton in GetX `InitialBinding`.
- Base configuration:
  - `baseUrl` sourced from active flavor configuration (`AppFlavor.baseUrl`).
  - `connectTimeout: const Duration(seconds: 30)`.
  - `receiveTimeout: const Duration(seconds: 30)`.
  - Default JSON headers: `'Content-Type': 'application/json'`, `'Accept': 'application/json'`.
- Interceptor execution pipeline strictly registered in order:
  1. `ConnectivityInterceptor`: Pre-flight check with `network_info.dart` (`connectivity_plus`). Short-circuits with `NetworkFailure` when offline before hitting the wire.
  2. `AuthInterceptor`: Attaches `Authorization: Bearer <token>` from `SecureStorageService`. Uses `QueuedInterceptorsWrapper` to pause incoming requests during 401s, executes atomic token refresh, retries queued calls, or triggers global auth state notification on terminal auth failure.
  3. `LoggingInterceptor`: Pretty request/response/error logs, strictly wrapped in `if (kDebugMode)` to ensure zero log leakage in release builds.
  4. `ErrorInterceptor`: Maps uncaught transport errors into typed domain `Failure` instances attached to `DioException.error` (via `err.copyWith(error: failure)`) with localized/human-readable error messages.
- **Architectural Boundary**: All network operations are confined to `RemoteDataSource` implementations. ViewModels and Repositories never call `Dio` directly. Repositories wrap data source responses into `Future<Either<Failure, T>>` using `fpdart`.

### 3.2 Race-Condition-Safe Token Refresh Blueprint

Below is the required production blueprint for `AuthInterceptor`. It uses a secondary clean `Dio` instance without interceptors (`_refreshDio`) to prevent infinite recursive 401 loops, checks for tokens already refreshed in-flight, excludes public endpoints, and decouples token refresh failure from replay failures:

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../../../core/constants/api_endpoints.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/storage/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final SecureStorageService _storage;
  final Dio _refreshDio; // Clean Dio instance with NO interceptors attached
  final void Function()? onAuthenticationExpired;

  AuthInterceptor({
    required SecureStorageService storage,
    required Dio refreshDio,
    this.onAuthenticationExpired,
  })  : _storage = storage,
        _refreshDio = refreshDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // 1. Skip refresh logic for public or auth endpoints to prevent loops
      if (err.requestOptions.path == ApiEndpoints.login) {
        return handler.next(err);
      }

      // 2. In-flight race check: verify if another request already refreshed the token
      final currentAccessToken = await _storage.getAccessToken();
      final sentToken = err.requestOptions.headers['Authorization'] as String?;
      if (currentAccessToken != null &&
          currentAccessToken.isNotEmpty &&
          sentToken != 'Bearer $currentAccessToken') {
        // Token was already refreshed by a prior concurrent request; replay immediately
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $currentAccessToken';
        try {
          final cloneResponse = await _refreshDio.fetch(retryOptions);
          return handler.resolve(cloneResponse);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      }

      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _handleLogout();
        return handler.next(err);
      }

      // 3. Block 1: Atomic token refresh execution
      String newAccessToken;
      try {
        // QueuedInterceptorsWrapper automatically locks and queues concurrent requests
        final response = await _refreshDio.post<Map<String, dynamic>>(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        final data = response.data;
        final token = data?['accessToken'] as String?;
        final newRefreshToken = data?['refreshToken'] as String?;

        if (token == null || token.isEmpty) {
          throw DioException(
            requestOptions: err.requestOptions,
            error: 'Invalid refresh token response payload',
          );
        }

        await _storage.saveTokens(
          accessToken: token,
          refreshToken: newRefreshToken ?? refreshToken,
        );
        newAccessToken = token;
      } catch (refreshError) {
        await _handleLogout();
        return handler.next(err);
      }

      // 4. Block 2: Replay original request (decoupled from refresh error handling)
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      try {
        final cloneResponse = await _refreshDio.fetch(retryOptions);
        return handler.resolve(cloneResponse);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      }
    }
    handler.next(err);
  }

  Future<void> _handleLogout() async {
    await _storage.clearTokens();
    // Trigger global auth state notification / event callback rather than hard routing
    if (onAuthenticationExpired != null) {
      onAuthenticationExpired!();
    } else {
      // Fallback: Notify router or navigate to login
      getx.Get.offAllNamed(AppRoutes.login);
    }
  }
}
```

### 3.3 ErrorInterceptor Blueprint
Maps transport-level `DioException` types to domain `Failure` contracts attached to `DioException.error` using `err.copyWith(error: mappedFailure)` so `ErrorInterceptorHandler` contracts remain strictly type-safe with Dio:
- `DioExceptionType.connectionTimeout`, `sendTimeout`, `receiveTimeout` → `NetworkFailure('Connection timed out. Please try again.')`
- `DioExceptionType.connectionError` → `NetworkFailure('No internet connection.')`
- `DioExceptionType.badResponse` → Extracts backend message or returns `ServerFailure('Server error (${statusCode})')`
- `DioExceptionType.cancel` → Ignored or mapped to custom `CancelledFailure`

Example implementation pattern in `ErrorInterceptor.onError`:
```dart
@override
void onError(DioException err, ErrorInterceptorHandler handler) {
  final failure = _mapDioExceptionToFailure(err);
  handler.next(err.copyWith(error: failure));
}
```
`RemoteDataSource` implementations throw `DioException` (or custom data exceptions), which `Repository` implementations catch and map to `Left(failure)`.

---

## 4. State Management (GetX) & UI State Modeling

### 4.1 Reactive State with Value Equality
- Model UI state as an immutable hierarchy extending `Equatable`:
```dart
import 'package:equatable/equatable.dart';

abstract class ViewState extends Equatable {
  const ViewState();
  @override
  List<Object?> get props => [];
}

class IdleState extends ViewState {
  const IdleState();
}

class LoadingState extends ViewState {
  const LoadingState();
}

class SuccessState<T> extends ViewState {
  final T data;
  const SuccessState(this.data);
  @override
  List<Object?> get props => [data];
}

class ErrorState extends ViewState {
  final String message;
  const ErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
```
- In `GetxController`:
  - Declare reactive state: `final state = Rx<ViewState>(const IdleState());`
  - Rebuild views reactively using `Obx(() => ...)` targeting only state-dependent widgets.
  - Controllers coordinate UseCases/Repositories and never interact directly with Dio, storage, or low-level data sources.
- Screens extend `GetView<TController>` (or `GetWidget<TController>`) instead of `StatefulWidget` for clean, boilerplate-free controller access via `controller`.

---

## 5. Dependency Injection — GetX Bindings

- **Single DI Mechanism**: Strictly use GetX Bindings (`Get.put`, `Get.lazyPut`, `Get.find`). Strictly **ZERO references to `get_it` or `injectable`**.
- **`InitialBinding` (Core Permanent Singletons)**:
  - Registered globally on `GetMaterialApp(initialBinding: InitialBinding())`.
  - Binds permanent core infrastructure services:
  ```dart
  import 'package:get/get.dart';
  import '../network/dio_client.dart';
  import '../storage/local_cache_service.dart';
  import '../storage/secure_storage_service.dart';

  class InitialBinding extends Bindings {
    @override
    void dependencies() {
      Get.put<SecureStorageService>(SecureStorageService(), permanent: true);
      Get.put<LocalCacheService>(LocalCacheService(), permanent: true);
      Get.put<DioClient>(DioClient(storage: Get.find()), permanent: true);
    }
  }
  ```
- **Feature `Bindings` (Route-Scoped Lazy Injection)**:
  - Injected lazily only when route is visited and disposed on route pop (unless `fenix: true` is configured):
  ```dart
  import 'package:get/get.dart';
  import '../../features/auth/data/datasources/auth_remote_data_source.dart';
  import '../../features/auth/data/repositories/auth_repository_impl.dart';
  import '../../features/auth/domain/repositories/auth_repository.dart';
  import '../../features/auth/domain/usecases/login_usecase.dart';
  import '../../features/auth/presentation/controllers/auth_controller.dart';
  import '../network/dio_client.dart';

  class AuthBinding extends Bindings {
    @override
    void dependencies() {
      Get.lazyPut<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(dio: Get.find<DioClient>().dio),
      );
      Get.lazyPut<AuthRepository>(
        () => AuthRepositoryImpl(
          remoteDataSource: Get.find(),
          storageService: Get.find(),
        ),
      );
      Get.lazyPut<LoginUseCase>(() => LoginUseCase(repository: Get.find()));
      Get.lazyPut<AuthController>(() => AuthController(loginUseCase: Get.find()));
    }
  }
  ```
- Repositories and UseCases are always defined as abstract interfaces in `domain/`; concrete implementations are wired in `Bindings`.

---

## 6. Storage Strategy & Separation of Concerns

- **`SecureStorageService` (`flutter_secure_storage`)**: Exclusively stores sensitive credentials (`accessToken`, `refreshToken`, encryption keys). Never store raw credentials or auth tokens in unencrypted storage.
- **`LocalCacheService` (`hive_flutter`)**: Stores non-sensitive app and user data (cached user profiles, theme mode, selected language/locale, app settings) for fast cold-start reads and offline capability.
- **Session Revocation & Auth Event Bus**: When token refresh fails or user logs out, `SecureStorageService` and `LocalCacheService` session caches are cleared, and a reactive auth state stream or `onAuthenticationExpired` callback notifies the routing layer to execute `Get.offAllNamed(AppRoutes.login)`.

---

## 7. Repository Pattern & Architectural Boundaries

- `domain/repositories/*.dart`: Pure Dart abstract interfaces. Zero imports from `flutter/`, `dio`, `get`, or third-party serialization libraries.
- `data/repositories/*_impl.dart`: Implements the domain contract, orchestrates `RemoteDataSource` and `LocalDataSource`, maps DTOs to domain `Entity` objects, and returns `Future<Either<Failure, T>>` using `fpdart`.
- ViewModels / Controllers depend only on abstract repository interfaces or UseCases, injected via GetX Bindings (`Get.find()`).

---

## 8. Models & Serialization — `json_serializable` (no hand-written JSON code)

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

## 9. Localization (Bangla + English)

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

## 10. Theming / Colors / Font Sizes (centralized in `core/theme`)

- `AppColors` — static const colors + light/dark variants; no raw hex codes in widgets.
- `AppTextStyles` — named text styles (`heading1`, `bodyMedium`, `caption`, etc.)
  built on `google_fonts` or a bundled font family.
- `AppDimens`/spacing — use `flutter_screenutil` (`.sp`, `.w`, `.h`, `.r`) for
  responsive sizing across devices, defined once and reused everywhere.
- `AppTheme.light()` / `AppTheme.dark()` — full `ThemeData`, toggle via
  `ThemeProvider` persisted in cache.

---

## 11. Error Handling

- `core/error/failures.dart` — `Failure` classes extend **`Equatable`**
  (`ServerFailure`, `NetworkFailure`, `CacheFailure`, `AuthFailure`,
  `ValidationFailure`), each overriding `props` (typically `[message]`) so two
  failures with the same message compare equal in tests and state comparisons.
- `core/error/exceptions.dart` — low-level exceptions thrown by data sources,
  caught and converted to `Failure` in the Repository layer.
- A shared `ErrorMapper`/`ErrorHandler` widget or `SnackBar` utility standardizes
  how failures are shown to the user.

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
