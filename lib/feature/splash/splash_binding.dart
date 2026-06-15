import 'package:get/get.dart';
import 'package:ohmie_customer/feature/splash/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SplashController>()) {
      Get.put(SplashController());
    }
  }
}
