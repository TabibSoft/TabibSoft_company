import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Abstract interface for app configuration service.
/// Allows replacing Remote Config with API, Firestore, or License server.
abstract class AppConfigService {
  Future<void> init();
  Future<bool> fetchAndActivate();
  bool getBool(String key);
  String getString(String key);
  int getInt(String key);
}

/// [FRConfig] is stands for Firebase Remote Config
class FRConfig implements AppConfigService {
  static final FRConfig instance = FRConfig._();
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  FRConfig._() {
    setupRemoteConfig();
    _isUpdateExist();
  }

  @override
  Future<void> init() async {
    await setupRemoteConfig();
  }

  @override
  Future<bool> fetchAndActivate() async {
    return await _remoteConfig.fetchAndActivate();
  }

  @override
  bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }

  @override
  String getString(String key) {
    return _remoteConfig.getString(key);
  }

  @override
  int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  /// Check if the app is enabled via Remote Config
  bool get isAppEnabled {
    if (kDebugMode) return true; // Always enabled in debug mode
    return _remoteConfig.getBool('app_enabled');
  }

  /// Check Remote Config if the ['force_update'] is true, the app will navigate
  /// to force updating page, if not the app will behave normally.
  bool? get _isForceUpdate {
    // if (kDebugMode) return false;
    if (Platform.isIOS) {
      return _remoteConfig.getBool('force_update_ios');
    } else {
      return _remoteConfig.getBool('force_update');
    }
  }

  String get contactUsLink {
    if (Platform.isIOS) {
      return _remoteConfig.getString('contact_us_link_ios');
    } else {
      return _remoteConfig.getString('contact_us_link');
    }
  }

  String get storeAppLink {
    if (Platform.isIOS) {
      return _remoteConfig.getString('app_link_ios');
    } else {
      return _remoteConfig.getString('app_link');
    }
  }

  /// Setup FCR configurations.

  Future<String> _getAppInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  Future<bool> _isUpdateExist() async {
    final String getAppInfo = await _getAppInfo();
    final int? buildNumber = int.tryParse(getAppInfo);
    final int configBuildNumber = Platform.isIOS
        ? _remoteConfig.getInt('build_number_ios')
        : _remoteConfig.getInt('build_number');
    debugPrint(
        'build number: $buildNumber, config build number: $configBuildNumber');
    return configBuildNumber > buildNumber! ? true : false;
  }

  bool get isAppUnderMaintenance {
    // if (kDebugMode) return false;
    return _remoteConfig.getBool('is_under_maintenance');
  }

  Future<bool> isNeedForceUpdate() async {
    final bool isUpdateExist = await _isUpdateExist();
    debugPrint('isUpdateExist: $isUpdateExist');
    return _isForceUpdate! && isUpdateExist ? true : false;
  }

  Future<FirebaseRemoteConfig> setupRemoteConfig() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );

    await _remoteConfig.activate();
    await Future.delayed(const Duration(seconds: 1));
    await _remoteConfig.fetchAndActivate();
    return _remoteConfig;
  }

  String appLink() {
    debugPrint('appLinkkkkkkkkkkkkkkkkkkkkk : $storeAppLink');
    return storeAppLink;
  }
}
