import 'package:get/get.dart';
import 'package:ohmie_customer/feature/profile/profile_controller.dart';
import 'package:ohmie_customer/feature/profile/profile_service.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileService>(() => ProfileService(Get.find()), fenix: true);
    Get.lazyPut<ProfileController>(
      () => ProfileController(Get.find(), Get.find()),
    );
  }
}
