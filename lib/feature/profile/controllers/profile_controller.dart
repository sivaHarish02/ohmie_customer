import 'package:get/get.dart';
import 'package:ohmie_customer/core/services/storage_service.dart';
import 'package:ohmie_customer/core/services/socket_service.dart';

class ProfileController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final SocketService _socketService = Get.find<SocketService>();

  final Rxn<Map<String, dynamic>> user = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    final userData = _storageService.getUser();
    if (userData != null) {
      user.value = userData;
    }
  }

  String get name {
    if (user.value == null) return '';
    return (user.value!['name'] as String?) ?? '';
  }

  String get mobile {
    if (user.value == null) return '';
    return (user.value!['mobile'] as String?) ??
        (user.value!['phone'] as String?) ??
        '';
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    _socketService.disconnect();
    Get.offAllNamed('/login');
  }
}
