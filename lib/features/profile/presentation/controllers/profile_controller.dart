import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfileController extends GetxController {
  final DioClient dioClient;
  final LocalCacheService cacheService;
  final FlatContextService flatService;
  final SecureStorageService? secureStorageService;

  final Rx<UserEntity?> user = Rx<UserEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool isLoggingOut = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);
  late final Rx<Locale> currentLocale;

  ProfileController({
    required this.dioClient,
    required this.cacheService,
    required this.flatService,
    this.secureStorageService,
  }) {
    final cachedLang = cacheService.get<String>(StorageKeys.appLocale);
    currentLocale = Rx<Locale>(
      cachedLang != null && cachedLang.isNotEmpty
          ? Locale(cachedLang)
          : (Get.locale ?? const Locale('en')),
    );
  }

  @override
  void onInit() {
    super.onInit();
    _loadCachedUser();
    fetchProfile();
  }

  void _loadCachedUser() {
    final cached = cacheService.get<String>(StorageKeys.userProfile);
    if (cached != null && cached.isNotEmpty) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        user.value = UserModel.fromJson(map).toEntity();
      } catch (_) {}
    }
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await dioClient.dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      final rawData = response.data;
      if (rawData != null) {
        final dataWrapper = rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData;
        final userData = dataWrapper['user'] as Map<String, dynamic>?;
        if (userData != null) {
          final model = UserModel.fromJson(userData);
          user.value = model.toEntity();
          await cacheService.put<String>(
            StorageKeys.userProfile,
            jsonEncode(model.toJson()),
          );
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    errorMessage.value = null;
    if (newPassword != confirmPassword) {
      errorMessage.value = 'Passwords do not match';
      return false;
    }

    isChangingPassword.value = true;
    try {
      final response = await dioClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );
      final status = response.statusCode ?? 0;
      return status >= 200 && status < 300;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> switchLanguage(Locale locale) async {
    currentLocale.value = locale;
    await Get.updateLocale(locale);
    await cacheService.put<String>(StorageKeys.appLocale, locale.languageCode);
  }

  Future<void> logout() async {
    isLoggingOut.value = true;
    try {
      await dioClient.dio.post<dynamic>(ApiEndpoints.logout);
    } catch (_) {}

    final storage = secureStorageService ??
        (Get.isRegistered<SecureStorageService>()
            ? Get.find<SecureStorageService>()
            : null);
    await storage?.clearTokens();
    flatService.clear();
    await cacheService.delete(StorageKeys.userProfile);

    isLoggingOut.value = false;
    await Get.offAllNamed<dynamic>(AppRoutes.login);
  }
}
