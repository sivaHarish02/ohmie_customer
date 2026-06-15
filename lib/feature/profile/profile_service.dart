import 'package:ohmie_customer/core/services/storage_service.dart';

class ProfileService {
  ProfileService(this._storageService);

  final StorageService _storageService;

  Future<Map<String, dynamic>> getProfile() async {
    return _storageService.getUser() ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateProfile({
    required String email,
    required String avatarUrl,
  }) async {
    final existing = _storageService.getUser() ?? <String, dynamic>{};
    final updated = Map<String, dynamic>.from(existing)
      ..['email'] = email.trim()
      ..['avatarUrl'] = avatarUrl.trim();

    await _storageService.saveUser(updated);
    return updated;
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }
}
