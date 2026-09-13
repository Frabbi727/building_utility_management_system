import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../firebase_options.dart';
import '../constants/api_endpoints.dart';
import '../network/dio_client.dart';
import '../routing/notification_router.dart';
import '../storage/secure_storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
  debugPrint('Background notification received: ${message.messageId}');
}

class FirebaseNotificationService extends GetxService {
  final DioClient? dioClient;
  final SecureStorageService? storageService;

  FirebaseNotificationService({
    this.dioClient,
    this.storageService,
  });

  static const String _deviceIdKey = 'fcm_device_id';
  static const String _channelId = 'uas_channel_alerts';
  static const String _channelName = 'Building Notifications';
  static const String _channelDescription = 'Alerts for bills, payments, notices, and building maintenance';

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<FirebaseNotificationService> init() async {
    if (_isInitialized) return this;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      await _setupLocalNotifications();
      await _requestPermissions();
      _setupMessageListeners();

      _isInitialized = true;
      debugPrint('FirebaseNotificationService initialized successfully');
    } catch (e) {
      debugPrint('FirebaseNotificationService initialization error: $e');
    }

    return this;
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            NotificationRouter.handlePayload(data);
          } catch (_) {}
        }
      },
    );

    // Create high importance Android notification channel
    if (!kIsWeb && Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(androidChannel);
    }
  }

  Future<void> _requestPermissions() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _setupMessageListeners() {
    // 1. Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
      _showForegroundAlert(message);
    });

    // 2. Notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened from background: ${message.data}');
      NotificationRouter.handleMessage(message);
    });

    // 3. Token refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      syncDeviceRegistration(tokenOverride: newToken);
    });

    // 4. Initial message when app opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('App launched from terminated notification: ${message.data}');
        NotificationRouter.handleMessage(message);
      }
    });
  }

  Future<void> _showForegroundAlert(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }

  /// Syncs current hardware ID and FCM token to the backend.
  Future<bool> syncDeviceRegistration({String? tokenOverride}) async {
    final client = dioClient ?? (Get.isRegistered<DioClient>() ? Get.find<DioClient>() : null);
    if (client == null) return false;

    try {
      final token = tokenOverride ?? await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('No FCM token available to register');
        return false;
      }

      final deviceId = await getOrCreateDeviceId();
      final deviceInfo = await _collectDeviceInfo();

      final response = await client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.registerDevice,
        data: {
          'device_id': deviceId,
          'device_token': token,
          'platform': deviceInfo['platform'],
          'device_model': deviceInfo['device_model'],
          'os_version': deviceInfo['os_version'],
          'app_version': deviceInfo['app_version'],
        },
      );

      final status = response.statusCode ?? 0;
      final success = status >= 200 && status < 300;
      debugPrint('Device registered with backend: success=$success');
      return success;
    } catch (e) {
      debugPrint('Failed to sync device registration: $e');
      return false;
    }
  }

  /// Deactivates this device on the backend upon logout.
  Future<void> unregisterDevice() async {
    final client = dioClient ?? (Get.isRegistered<DioClient>() ? Get.find<DioClient>() : null);
    if (client == null) return;

    try {
      final deviceId = await getOrCreateDeviceId();
      await client.dio.delete<dynamic>(ApiEndpoints.deleteDevice(deviceId));
      debugPrint('Device deactivated on backend: $deviceId');
    } catch (e) {
      debugPrint('Failed to unregister device: $e');
    }
  }

  /// Retrieves or generates a persistent device UUID.
  Future<String> getOrCreateDeviceId() async {
    final storage = storageService ?? (Get.isRegistered<SecureStorageService>() ? Get.find<SecureStorageService>() : null);
    if (storage != null) {
      final storedId = await storage.storage.read(key: _deviceIdKey);
      if (storedId != null && storedId.isNotEmpty) {
        return storedId;
      }
    }

    final newId = 'dev-${DateTime.now().millisecondsSinceEpoch}-${UniqueKey().hashCode}';
    if (storage != null) {
      await storage.storage.write(key: _deviceIdKey, value: newId);
    }
    return newId;
  }

  Future<Map<String, String>> _collectDeviceInfo() async {
    final plugin = DeviceInfoPlugin();
    String platform = 'android';
    String model = 'Unknown';
    String os = '';
    String appVersion = '1.0.0';

    try {
      final pkg = await PackageInfo.fromPlatform();
      appVersion = '${pkg.version}+${pkg.buildNumber}';
    } catch (_) {}

    try {
      if (!kIsWeb && Platform.isAndroid) {
        platform = 'android';
        final info = await plugin.androidInfo;
        model = '${info.manufacturer} ${info.model}';
        os = 'Android ${info.version.release} (SDK ${info.version.sdkInt})';
      } else if (!kIsWeb && Platform.isIOS) {
        platform = 'ios';
        final info = await plugin.iosInfo;
        model = info.utsname.machine;
        os = '${info.systemName} ${info.systemVersion}';
      }
    } catch (_) {}

    return {
      'platform': platform,
      'device_model': model,
      'os_version': os,
      'app_version': appVersion,
    };
  }
}
