import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ohmie_customer/core/constants/app_constants.dart';

class StorageService extends GetxService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  Map<String, dynamic>? _user;
  String? _fcmToken;
  bool _onboardingDone = false;

  Future<StorageService> init() async {
    _token = await _storage.read(key: AppConstants.tokenKey);

    final rawUser = await _storage.read(key: AppConstants.userKey);
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        _user = jsonDecode(rawUser) as Map<String, dynamic>;
      } catch (_) {
        _user = null;
      }
    }

    _fcmToken = await _storage.read(key: AppConstants.fcmTokenKey);
    _onboardingDone =
        (await _storage.read(key: AppConstants.onboardingKey)) == 'true';

    return this;
  }

  // ---------------------------------------------------------------------------
  // Token
  // ---------------------------------------------------------------------------

  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  String? getToken() {
    return _token;
  }

  Future<void> removeToken() async {
    _token = null;
    await _storage.delete(key: AppConstants.tokenKey);
  }

  // ---------------------------------------------------------------------------
  // User Data
  // ---------------------------------------------------------------------------

  Future<void> saveUser(Map<String, dynamic> data) async {
    _user = data;
    await _storage.write(
      key: AppConstants.userKey,
      value: jsonEncode(data),
    );
  }

  Map<String, dynamic>? getUser() {
    return _user;
  }

  Future<void> removeUser() async {
    _user = null;
    await _storage.delete(key: AppConstants.userKey);
  }

  // ---------------------------------------------------------------------------
  // FCM Token
  // ---------------------------------------------------------------------------

  Future<void> saveFcmToken(String token) async {
    _fcmToken = token;
    await _storage.write(key: AppConstants.fcmTokenKey, value: token);
  }

  String? getFcmToken() {
    return _fcmToken;
  }

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------

  Future<void> setOnboardingDone() async {
    _onboardingDone = true;
    await _storage.write(key: AppConstants.onboardingKey, value: 'true');
  }

  bool get isOnboardingDone {
    return _onboardingDone;
  }

  // ---------------------------------------------------------------------------
  // Generic helpers
  // ---------------------------------------------------------------------------

  Future<void> write(String key, dynamic value) async {
    await _storage.write(key: key, value: value?.toString());
  }

  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  /// Clears all stored data (used on logout).
  Future<void> clearAll() async {
    _token = null;
    _user = null;
    _fcmToken = null;
    _onboardingDone = false;
    await _storage.deleteAll();
  }

  // ---------------------------------------------------------------------------
  // Computed properties
  // ---------------------------------------------------------------------------

  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}
