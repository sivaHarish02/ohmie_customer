import 'package:get/get.dart';

import 'package:ohmie_customer/core/network/api_client.dart';
import 'package:ohmie_customer/core/services/socket_service.dart';
import 'package:ohmie_customer/feature/tracking/controllers/tracking_controller.dart';

class TrackingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient());
      Get.find<ApiClient>().init();
    }

    if (!Get.isRegistered<SocketService>()) {
      Get.put<SocketService>(SocketService(), permanent: true);
    }

    Get.lazyPut<TrackingController>(
      () => TrackingController(),
    );
  }
}
