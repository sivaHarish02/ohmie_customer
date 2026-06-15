import 'package:get/get.dart';

import 'package:ohmie_customer/feature/auth/auth_controller.dart';
import 'package:ohmie_customer/feature/auth/auth_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(Get.find()), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(Get.find(), Get.find()));
  }
}
