import 'package:get/get.dart';
import 'package:ohmie_customer/feature/home/home_controller.dart';
import 'package:ohmie_customer/feature/home/home_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeService>(() => HomeService(Get.find()), fenix: true);
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find(), Get.find()),
    );
  }
}
