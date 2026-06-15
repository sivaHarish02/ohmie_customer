import 'package:get/get.dart';
import 'package:ohmie_customer/core/routes/app_routes.dart';
import 'package:ohmie_customer/core/services/storage_service.dart';
import 'package:ohmie_customer/feature/profile/profile_service.dart';

class ProfileController extends GetxController {
  ProfileController(this._service, this._storageService);

  final ProfileService _service;
  final StorageService _storageService;

  final user = <String, dynamic>{}.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    isLoading.value = true;
    try {
      user.assignAll(await _service.getProfile());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await _loadProfile();
  }

  String get name => (user['name'] ?? 'Customer').toString();
  String get mobile => (user['mobile'] ?? user['phone'] ?? '').toString();
  String get email => (user['email'] ?? '').toString();
  String get avatarUrl => (user['avatarUrl'] ?? '').toString();
  bool get hasAvatarUrl => avatarUrl.isNotEmpty;
  String get avatarInitial => name.isNotEmpty ? name[0].toUpperCase() : 'C';
  String get memberSince {
    final raw = user['createdAt']?.toString();
    if (raw == null || raw.isEmpty) return 'Recently joined';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'Recently joined';
    return 'Member since ${dt.year}';
  }

  Future<void> updateProfile({
    required String email,
    required String avatarUrl,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isNotEmpty && !_isValidEmail(trimmedEmail)) {
      Get.snackbar(
        'Profile',
        'Please enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final updated = await _service.updateProfile(
        email: trimmedEmail,
        avatarUrl: avatarUrl.trim(),
      );
      user.assignAll(updated);

      Get.snackbar(
        'Profile',
        'Profile updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidEmail(String value) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(value);
  }

  Future<void> logout() async {
    await _service.logout();
    await _storageService.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}
