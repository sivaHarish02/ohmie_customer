import 'package:get/get.dart';

import 'package:ohmie_customer/feature/location/controllers/location_controller.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationController>(
      () => LocationController(),
      fenix: true,
    );
  }
}
