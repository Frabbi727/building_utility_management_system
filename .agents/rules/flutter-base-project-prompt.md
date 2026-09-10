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
│   ├── base/                       # view_state.dart (sealed class ViewState)
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
  output-dir: lib/core/localization
  synthetic-package: false
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

### `core/base/view_state.dart`
- Model UI state as an immutable hierarchy extending `Equatable`:
```dart
import 'package:equatable/equatable.dart';

sealed class ViewState extends Equatable {
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
  import 'package:connectivity_plus/connectivity_plus.dart';
  import 'package:get/get.dart';
  import '../network/dio_client.dart';
  import '../network/network_info.dart';
  import '../storage/local_cache_service.dart';
  import '../storage/secure_storage_service.dart';

  class InitialBinding extends Bindings {
    @override
    void dependencies() {
      Get.put<SecureStorageService>(SecureStorageService(), permanent: true);
      Get.put<LocalCacheService>(LocalCacheService(), permanent: true);
      Get.put<NetworkInfo>(NetworkInfoImpl(Connectivity()), permanent: true);
      Get.put<DioClient>(DioClient(storage: Get.find<SecureStorageService>()), permanent: true);
    }
  }
  ```
- **Feature `Bindings` (Route-Scoped Lazy Injection)**:
  - Injected lazily only when route is visited and disposed on route pop (unless `fenix: true` is configured):
  ```dart
  import 'package:get/get.dart';
  import '../../../../core/network/dio_client.dart';
  import '../../../../core/storage/secure_storage_service.dart';
  import '../../data/datasources/auth_local_data_source.dart';
  import '../../data/datasources/auth_remote_data_source.dart';
  import '../../data/repositories/auth_repository_impl.dart';
  import '../../domain/repositories/auth_repository.dart';
  import '../../domain/usecases/login_usecase.dart';
  import '../controllers/auth_controller.dart';

  class AuthBinding extends Bindings {
    @override
    void dependencies() {
      Get.lazyPut<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(dio: Get.find<DioClient>().dio),
      );
      Get.lazyPut<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(storageService: Get.find<SecureStorageService>()),
      );
      Get.lazyPut<AuthRepository>(
        () => AuthRepositoryImpl(
          remoteDataSource: Get.find<AuthRemoteDataSource>(),
          localDataSource: Get.find<AuthLocalDataSource>(),
        ),
      );
      Get.lazyPut<LoginUseCase>(
        () => LoginUseCase(repository: Get.find<AuthRepository>()),
      );
      Get.lazyPut<AuthController>(
        () => AuthController(loginUseCase: Get.find<LoginUseCase>()),
      );
    }
  }
  ```
- Repositories and UseCases are always defined as abstract interfaces in `domain/`; concrete implementations are wired in `Bindings`.

---

## 6. Storage Strategy & Separation of Concerns

- **`SecureStorageService` (`flutter_secure_storage`)**: Exclusively stores sensitive credentials (`accessToken`, `refreshToken`, encryption keys). Never store raw credentials or auth tokens in unencrypted storage. Maintains a synchronous in-memory `String? get cachedAccessToken` (cached in memory on init, updated on `saveTokens()`, cleared on `clearTokens()`) so route middlewares like `AuthMiddleware` can check authentication synchronously without async latency.
- **`LocalCacheService` (`hive_flutter`)**: Stores non-sensitive app and user data (cached user profiles, theme mode, selected language/locale, app settings) for fast cold-start reads and offline capability.
- **Session Revocation & Auth Event Bus**: When token refresh fails or user logs out, `SecureStorageService` and `LocalCacheService` session caches are cleared, and a reactive auth state stream or `onAuthenticationExpired` callback notifies the routing layer to execute `Get.offAllNamed(AppRoutes.login)`.

---

## 7. Repository Pattern & Architectural Boundaries

- `domain/repositories/*.dart`: Pure Dart abstract interfaces. Zero imports from `flutter/`, `dio`, `get`, or third-party serialization libraries.
- `data/repositories/*_impl.dart`: Implements the domain contract, orchestrates `RemoteDataSource` and `LocalDataSource`, maps DTOs to domain `Entity` objects, and returns `Future<Either<Failure, T>>` using `fpdart`.
- ViewModels / Controllers depend only on abstract repository interfaces or UseCases, injected via GetX Bindings (`Get.find()`).

---

## 8. Models & Serialization — `json_serializable`

- Every data-layer model/DTO in `features/<feature>/data/models/` must be annotated with `@JsonSerializable()`:
```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() => UserEntity(id: id, name: name, email: email);

  @override
  List<Object?> get props => [id, name, email];
}
```
- **Strict Invariant**: The single-line factory `_$ModelFromJson(json)` and method `_$ModelToJson(this)` signatures are written manually; the actual field serialization body is **always generated into `*.g.dart`** via `build_runner`. Never hand-write or manually edit JSON serialization logic.
- Run code generation:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- **Domain Entities vs Data Models**:
  - `domain/entities/*.dart`: Pure Dart business representations extending `Equatable`. Strictly **no `json_annotation` or serialization logic**.
  - `data/models/*.dart`: Concrete DTOs extending `Equatable` that implement or map to/from domain entities (`toEntity()` / `fromEntity()`).

---

## 9. Functional Error Handling — `fpdart` & Typed Failures

- **Core Rule**: Avoid untyped exception throwing in domain and presentation layers. Data sources throw low-level `Exceptions`, repositories catch them and return `Either<Failure, T>` using `fpdart`.
- `core/error/failures.dart`:
```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection detected.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load cached data.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed. Please sign in again.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
```
- `core/error/exceptions.dart`: Defines low-level transport/storage exceptions (`ServerException`, `CacheException`, `NetworkException`).
- Controllers consume repository/use case responses via `.fold()`:
```dart
final result = await loginUseCase(params);
result.fold(
  (failure) => state.value = ErrorState(failure.message),
  (user) => state.value = SuccessState<UserEntity>(user),
);
```

---

## 10. Localization — Official Flutter Arb & Intl (Bangla + English)

- **Standardization**: Strictly use Flutter's official `flutter_localizations` + `intl` with `.arb` translation catalogs. Do **NOT** use GetX's `Translations` map class.
- Root configuration in `l10n.yaml`:
  ```yaml
  arb-dir: lib/core/localization/l10n
  template-arb-file: app_en.arb
  output-localization-file: app_localizations.dart
  output-dir: lib/core/localization
  synthetic-package: false
  untranslated-messages-file: untranslated_messages.json
  ```
- Translation catalogs:
  - `lib/core/localization/l10n/app_en.arb`: English strings (template).
  - `lib/core/localization/l10n/app_bn.arb`: Bangla translations.
- Code generation:
  ```bash
  flutter gen-l10n
  ```
- String access via BuildContext extension (`context.l10n.loginTitle`) defined in `lib/core/utils/extensions/context_ext.dart`:
  ```dart
  extension LocalizedContext on BuildContext {
    AppLocalizations get l10n => AppLocalizations.of(this)!;
  }
  ```
  No hardcoded strings in widgets.
- Runtime language switching: Persist selection in `LocalCacheService` and execute:
  ```dart
  Get.updateLocale(const Locale('bn', 'BD')); // or Locale('en', 'US')
  ```
- Support Bangla numeral and calendar formatting using `intl` with `'bn'` locale.

---

## 11. Centralized Theming & Responsive Layout (`core/theme`)

- **`AppColors`**: Static constant color palette (`AppColors.primary`, `AppColors.backgroundLight`, etc.). Never write raw hex codes (`0xFF...`) directly in UI widgets.
- **`AppTextStyles`**: Type scale definitions (`headlineLarge`, `bodyMedium`, `labelSmall`) utilizing `google_fonts` or bundled fonts.
- **`AppDimens` & Responsive Sizing (`flutter_screenutil`)**:
  - Root initialization in `app.dart`:
    ```dart
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(...),
    )
    ```
  - Use responsive extensions (`.w`, `.h`, `.r`, `.sp`) across all dimensions, paddings, and font sizes.
- **`AppTheme.light()` & `AppTheme.dark()`**: Full `ThemeData` specifications. Theme mode is persisted in `LocalCacheService` and toggled dynamically via `Get.changeThemeMode(ThemeMode.dark)`.

---

## 12. Routing & Route Guards — GetX

- `GetMaterialApp` configured with declarative named routes in `core/routing/app_pages.dart`:
  ```dart
  import 'package:get/get.dart';
  import '../../features/auth/presentation/bindings/auth_binding.dart';
  import '../../features/auth/presentation/screens/login_screen.dart';
  import 'route_names.dart';

  class AppPages {
    static const initial = AppRoutes.login;

    static final routes = <GetPage<dynamic>>[
      GetPage(
        name: AppRoutes.login,
        page: () => const LoginScreen(),
        binding: AuthBinding(),
      ),
      // Additional guarded routes attached with middlewares: [AuthMiddleware()]
    ];
  }
  ```
- **Static Route Names (`core/routing/route_names.dart`)**:
  ```dart
  abstract class AppRoutes {
    static const login = '/login';
    static const home = '/home';
    static const profile = '/profile';
    static const settings = '/settings';
  }
  ```
- **Navigation Invariant**: Use `Get.toNamed(...)`, `Get.offAllNamed(...)` — no `BuildContext` required, allowing clean navigation from controllers or auth expiration handlers.
- **Route Guards (`GetMiddleware`)**: Implement `AuthMiddleware extends GetMiddleware` overriding `redirect(String? route)` to verify token existence in `SecureStorageService` and redirect to `AppRoutes.login` if unauthenticated:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import '../storage/secure_storage_service.dart';
  import 'route_names.dart';

  class AuthMiddleware extends GetMiddleware {
    @override
    RouteSettings? redirect(String? route) {
      final storage = Get.find<SecureStorageService>();
      final token = storage.cachedAccessToken; // Synchronous cached token check
      if (route != AppRoutes.login && (token == null || token.isEmpty)) {
        return const RouteSettings(name: AppRoutes.login);
      }
      return null;
    }
  }
  ```

---

## 13. Environment Configuration & Flavors

- Support `dev`, `staging`, and `prod` configurations using compile-time constants via `--dart-define` or `--dart-define-from-file`.
- Abstract flavor configuration in `app/flavors/app_flavor.dart`:
  ```dart
  enum FlavorEnvironment { dev, staging, prod }

  class AppFlavor {
    static late final FlavorEnvironment environment;
    static late final String baseUrl;
    static late final String appName;

    static void initialize({
      required FlavorEnvironment env,
      required String apiBaseUrl,
      required String title,
    }) {
      environment = env;
      baseUrl = apiBaseUrl;
      appName = title;
    }
  }
  ```
- Secrets and keys are injected at build/CI time and **never** committed to version control.

---

## 14. Reference Vertical Slice: End-to-End Auth Pattern

Below is the complete canonical pattern that must be replicated across all features:

### 14.1 Remote Data Source (`data/datasources/auth_remote_data_source.dart`)
```dart
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  const AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<AuthResponseModel> login({required String email, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data!);
  }
}
```

### 14.2 Repository Implementation (`data/repositories/auth_repository_impl.dart`)
```dart
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(email: email, password: password);
      await _localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return Right(response.user.toEntity());
    } on DioException catch (e) {
      final failure = e.error is Failure
          ? e.error! as Failure
          : ServerFailure(e.message ?? 'Server error occurred');
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

### 14.3 UseCase (`domain/usecases/login_usecase.dart`)
```dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) => _repository.login(email: email, password: password);
}
```

### 14.4 ViewModel / Controller (`presentation/controllers/auth_controller.dart`)
```dart
import 'package:get/get.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/base/view_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

class AuthController extends GetxController {
  final LoginUseCase _loginUseCase;
  AuthController({required LoginUseCase loginUseCase}) : _loginUseCase = loginUseCase;

  final state = Rx<ViewState>(const IdleState());

  Future<void> login(String email, String password) async {
    state.value = const LoadingState();
    final result = await _loginUseCase(email: email, password: password);
    result.fold(
      (failure) => state.value = ErrorState(failure.message),
      (user) {
        state.value = SuccessState<UserEntity>(user);
        Get.offAllNamed(AppRoutes.home);
      },
    );
  }
}
```

### 14.5 View Screen (`presentation/screens/login_screen.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/utils/extensions/context_ext.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.loginTitle)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Obx(() {
          final currentState = controller.state.value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (currentState is ErrorState)
                Text(currentState.message, style: TextStyle(color: Colors.red, fontSize: 14.sp)),
              SizedBox(height: 16.h),
              if (currentState is LoadingState)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () => controller.login('user@example.com', 'secret'),
                  child: Text(context.l10n.loginButton),
                ),
            ],
          );
        }),
      ),
    );
  }
}
```

---

## 15. Standardized Core Package Matrix (`pubspec.yaml`)

| Purpose | Package | Version Floor | Notes |
|---|---|---|---|
| State / DI / Navigation | `get` | `^4.6.6` | Unified reactive state, bindings, declarative routes |
| Networking | `dio` | `^5.4.0` | Client with QueuedInterceptorsWrapper token refresh |
| Error Handling | `fpdart` | `^1.1.0` | Functional `Either<Failure, T>` return types |
| Value Equality | `equatable` | `^2.0.5` | Equality on entities, models, failures, and UI states |
| Model Serialization | `json_annotation` | `^4.9.0` | Annotations for code generator |
| Secure Storage | `flutter_secure_storage` | `^9.2.2` | Encrypted JWT token persistence |
| Offline Cache | `hive`, `hive_flutter` | `^2.2.3` (hive), `^1.1.0` (hive_flutter) | User preferences, theme, and locale cache |
| Responsive Layout | `flutter_screenutil` | `^5.9.3` | Adaptive typography and spacing (`.w`, `.h`, `.sp`) |
| Typography | `google_fonts` | `^6.2.1` | Cloud font loader with local asset fallback |
| Localization | `intl`, `flutter_localizations` | `^0.19.0`, `sdk: flutter` | Official `.arb` catalog code generation |
| Connectivity | `connectivity_plus` | `^6.0.3` | Pre-flight network status checker |
| Logging | `logger` | `^2.2.0` | Structured logging wrapped in `kDebugMode` |
| Env Config | `flutter_dotenv` | `^5.1.0` | Local development environment parsing |
| **Dev: Code Generation** | `build_runner`, `json_serializable` | `^2.4.9`, `^6.8.0` | Code generation for `*.g.dart` |
| **Dev: Testing** | `mocktail`, `get_test` | `^1.0.4`, `^7.4.2` | Mocking and GetX controller testing |
| **Dev: Lints** | `very_good_analysis` or `flutter_lints` | `^6.0.0` | Strict linter configuration |

---

## 16. Testing Strategy & Quality Assurance

- **Unit Testing Controllers & UseCases (`mocktail`)**:
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:fpdart/fpdart.dart';
  import 'package:get/get.dart';
  import 'package:mocktail/mocktail.dart';
  // Note: Replace <app_name> with the package name from pubspec.yaml
  import 'package:<app_name>/core/base/view_state.dart';
  import 'package:<app_name>/core/error/failures.dart';
  import 'package:<app_name>/features/auth/domain/entities/user_entity.dart';
  import 'package:<app_name>/features/auth/domain/usecases/login_usecase.dart';
  import 'package:<app_name>/features/auth/presentation/controllers/auth_controller.dart';

  class MockLoginUseCase extends Mock implements LoginUseCase {}

  void main() {
    late AuthController controller;
    late MockLoginUseCase mockLoginUseCase;

    const tUser = UserEntity(id: '1', name: 'John Doe', email: 'john@example.com');

    setUp(() {
      mockLoginUseCase = MockLoginUseCase();
      controller = AuthController(loginUseCase: mockLoginUseCase);
    });

    tearDown(() => Get.reset());

    test('initial state should be IdleState', () {
      expect(controller.state.value, equals(const IdleState()));
    });

    test('should emit [LoadingState, SuccessState] when login succeeds', () async {
      // Arrange
      when(() => mockLoginUseCase(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => const Right(tUser));

      // Act
      final future = controller.login('john@example.com', 'password123');

      // Assert
      expect(controller.state.value, equals(const LoadingState()));
      await future;
      expect(controller.state.value, equals(const SuccessState<UserEntity>(tUser)));
    });

    test('should emit [LoadingState, ErrorState] when login fails', () async {
      // Arrange
      const tFailure = ServerFailure('Invalid credentials');
      when(() => mockLoginUseCase(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final future = controller.login('john@example.com', 'wrong_password');

      // Assert
      expect(controller.state.value, equals(const LoadingState()));
      await future;
      expect(controller.state.value, equals(const ErrorState('Invalid credentials')));
    });
  }
  ```
- Controllers are tested in isolation by mocking abstract UseCases/Repositories and verifying `state.value` transitions (`IdleState` → `LoadingState` → `SuccessState` / `ErrorState`).
- Data sources tested with `mocktail` mocking `Dio` / `HttpClientAdapter`.
- Repositories tested verifying error mapping from `DioException` to `Left(Failure)`.

---

## 17. Agent Scaffolding Workflow & Verification Gates

When an AI coding assistant is tasked with scaffolding this starter project, it **must** execute the following checklist in sequence without omitting verification steps:

1. **Phase 1: Project & Dependency Setup**
   - Populate `pubspec.yaml` using the exact packages and version floors defined in Section 15.
   - Configure root `l10n.yaml` and `analysis_options.yaml`.
   - Run dependency installation:
     ```bash
     flutter pub get
     ```
2. **Phase 2: Core Infrastructure Scaffolding**
   - Scaffold `lib/app/` (`app.dart`, `bootstrap.dart`, `flavors/`).
   - Scaffold `lib/core/` (`base/`, `bindings/`, `constants/`, `error/`, `localization/`, `network/`, `routing/`, `storage/`, `theme/`, `utils/`, `widgets/`).
3. **Phase 3: Reference Vertical Slice**
   - Implement `lib/features/auth/` end-to-end following Section 14 blueprints.
   - Implement `app_en.arb` and `app_bn.arb` with authentication translation keys.
4. **Phase 4: Code Generation**
   - Run localization and model generation:
     ```bash
     flutter gen-l10n
     dart run build_runner build --delete-conflicting-outputs
     ```
5. **Phase 5: Automated Verification Gates (Mandatory)**
   - **Static Analysis Gate**:
     ```bash
     flutter analyze --fatal-infos
     ```
     *Pass criteria*: Zero errors, zero warnings, zero infos.
   - **Automated Test Gate**:
     ```bash
     flutter test
     ```
     *Pass criteria*: All unit and widget tests pass with 100% green status.
