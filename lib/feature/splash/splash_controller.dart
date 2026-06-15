import 'dart:developer';
import 'package:get/get.dart';
import 'package:ohmie_customer/core/routes/app_routes.dart';
import 'package:ohmie_customer/core/services/storage_service.dart';

class SplashController extends GetxController {
  bool _navigated = false;

  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    log('Checking authentication status...');
    await Future.delayed(const Duration(seconds: 2));
    if (_navigated || isClosed) return;
    log('Finished delay, proceeding with navigation check...');
    final storageService = Get.find<StorageService>();
    final token = storageService.getToken();
    _navigated = true;

    if (token != null && token.isNotEmpty) {
      log('User is authenticated. Navigating to home page...');
      Get.offAllNamed(AppRoutes.home);
    } else {
      log('No valid token found. Navigating to login page...');
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
