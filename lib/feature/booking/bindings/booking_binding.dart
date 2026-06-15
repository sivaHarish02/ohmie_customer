import 'package:get/get.dart';

import 'package:ohmie_customer/core/network/api_client.dart';
import 'package:ohmie_customer/feature/booking/controllers/booking_controller.dart';
import 'package:ohmie_customer/feature/booking/services/booking_service.dart';
import 'package:ohmie_customer/feature/location/controllers/location_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LocationController>()) {
      Get.lazyPut<LocationController>(() => LocationController(), fenix: true);
    }

    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(), permanent: true);
      Get.find<ApiClient>().init();
    }

    Get.lazyPut<BookingService>(() => BookingService(Get.find()), fenix: true);
    Get.lazyPut<BookingController>(() => BookingController(Get.find()));
  }
}
