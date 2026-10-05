import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../firebase_options.dart';
import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../core/routing/route_names.dart';
import '../core/services/firebase_auth_service.dart';
import '../core/services/firebase_notification_service.dart';
import '../core/services/firestore_service.dart';
import '../core/storage/local_cache_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../shared/services/flat_context_service.dart';
import 'app.dart';
import 'flavors/app_flavor.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final secureStorage = Get.isRegistered<SecureStorageService>()
        ? Get.find<SecureStorageService>()
        : Get.put<SecureStorageService>(SecureStorageService(), permanent: true);

    final localCache = Get.isRegistered<LocalCacheService>()
        ? Get.find<LocalCacheService>()
        : Get.put<LocalCacheService>(LocalCacheService(), permanent: true);

    if (!Get.isRegistered<FlatContextService>()) {
      Get.put<FlatContextService>(
        FlatContextService(cacheService: localCache),
        permanent: true,
      );
    }

    if (!Get.isRegistered<FirebaseAuthService>()) {
      Get.put<FirebaseAuthService>(FirebaseAuthService(), permanent: true);
    }

    if (!Get.isRegistered<FirestoreService>()) {
      Get.put<FirestoreService>(FirestoreService(), permanent: true);
    }

    final networkInfo = Get.isRegistered<NetworkInfo>()
        ? Get.find<NetworkInfo>()
        : Get.put<NetworkInfo>(NetworkInfoImpl(Connectivity()), permanent: true);

    if (!Get.isRegistered<DioClient>()) {
      Get.put<DioClient>(
        DioClient(
          baseUrl: AppFlavor.baseUrl,
          storage: secureStorage,
          networkInfo: networkInfo,
          onAuthenticationExpired: () => Get.offAllNamed<dynamic>(AppRoutes.login),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<FirebaseNotificationService>()) {
      Get.put<FirebaseNotificationService>(
        FirebaseNotificationService(
          dioClient: Get.find<DioClient>(),
          storageService: secureStorage,
        ),
        permanent: true,
      );
    }
  }
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  final secureStorage = Get.put<SecureStorageService>(SecureStorageService(), permanent: true);
  await secureStorage.init();

  final localCache = Get.put<LocalCacheService>(LocalCacheService(), permanent: true);
  await localCache.init();

  Get.put<FlatContextService>(FlatContextService(cacheService: localCache), permanent: true);
  Get.put<FirebaseAuthService>(FirebaseAuthService(), permanent: true);
  Get.put<FirestoreService>(FirestoreService(), permanent: true);

  final notificationService = Get.put<FirebaseNotificationService>(
    FirebaseNotificationService(
      storageService: secureStorage,
    ),
    permanent: true,
  );
  await notificationService.init();

  runApp(const MainApp());
}
