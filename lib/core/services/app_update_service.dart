import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService extends GetxService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static const String _paramMinVersion = 'min_required_version';
  static const String _paramLatestVersion = 'latest_version';
  static const String _paramUpdateTitle = 'update_title';
  static const String _paramUpdateMessage = 'update_message';
  static const String _paramPlayStoreUrl = 'play_store_url';

  static const String _defaultPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.techrealify.utilitynotesrofraf';

  Future<AppUpdateService> init() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? const Duration(seconds: 0)
              : const Duration(hours: 1),
        ),
      );

      await _remoteConfig.setDefaults(<String, dynamic>{
        _paramMinVersion: '1.0.0',
        _paramLatestVersion: '1.0.0',
        _paramUpdateTitle: 'Update Available',
        _paramUpdateMessage:
            'A new version of Utility Notes is available with performance improvements and new features.',
        _paramPlayStoreUrl: _defaultPlayStoreUrl,
      });

      await _remoteConfig.fetchAndActivate();
      debugPrint('AppUpdateService RemoteConfig initialized');
    } catch (e) {
      debugPrint('AppUpdateService RemoteConfig init error: $e');
    }

    return this;
  }

  /// Checks whether an update is available or required and prompts the user.
  Future<void> checkForUpdates({BuildContext? context}) async {
    if (kIsWeb) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "1.0.0"

      final minVersion = _remoteConfig.getString(_paramMinVersion);
      final latestVersion = _remoteConfig.getString(_paramLatestVersion);
      final title = _remoteConfig.getString(_paramUpdateTitle);
      final message = _remoteConfig.getString(_paramUpdateMessage);
      final storeUrl = _remoteConfig.getString(_paramPlayStoreUrl).isNotEmpty
          ? _remoteConfig.getString(_paramPlayStoreUrl)
          : _defaultPlayStoreUrl;

      debugPrint('Version Check -> Current: $currentVersion, Min: $minVersion, Latest: $latestVersion');

      final isHardUpdate = _compareVersions(currentVersion, minVersion) < 0;
      final isSoftUpdate = _compareVersions(currentVersion, latestVersion) < 0;

      if (isHardUpdate) {
        _showUpdateDialog(
          title: title.isNotEmpty ? title : 'Mandatory Update Required',
          message: 'To continue using Utility Notes, please update to the latest version ($minVersion).',
          storeUrl: storeUrl,
          isForced: true,
        );
      } else if (isSoftUpdate) {
        _showUpdateDialog(
          title: title.isNotEmpty ? title : 'New Version Available',
          message: message.isNotEmpty
              ? message
              : 'A new version of Utility Notes ($latestVersion) is ready to install.',
          storeUrl: storeUrl,
          isForced: false,
        );
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  /// Compares two semver strings: returns -1 if v1 < v2, 0 if v1 == v2, 1 if v1 > v2.
  int _compareVersions(String v1, String v2) {
    try {
      final clean1 = v1.split('+').first.trim();
      final clean2 = v2.split('+').first.trim();

      final parts1 = clean1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final parts2 = clean2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < 3; i++) {
        final num1 = i < parts1.length ? parts1[i] : 0;
        final num2 = i < parts2.length ? parts2[i] : 0;

        if (num1 < num2) return -1;
        if (num1 > num2) return 1;
      }
    } catch (_) {}
    return 0;
  }

  void _showUpdateDialog({
    required String title,
    required String message,
    required String storeUrl,
    required bool isForced,
  }) {
    Get.dialog(
      PopScope(
        canPop: !isForced,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isForced ? Icons.warning_amber_rounded : Icons.system_update_rounded,
                color: isForced ? Colors.orange.shade800 : Colors.blue.shade700,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            if (!isForced)
              TextButton(
                onPressed: () => Get.back<void>(),
                child: const Text('Later'),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _launchStoreUrl(storeUrl),
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
      barrierDismissible: !isForced,
    );
  }

  Future<void> _launchStoreUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch store URL: $e');
    }
  }
}
