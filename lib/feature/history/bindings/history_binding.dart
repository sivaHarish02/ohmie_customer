import 'package:get/get.dart';

import 'package:ohmie_customer/feature/history/controllers/history_controller.dart';
import 'package:ohmie_customer/feature/history/services/history_service.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryService>(
      () => HistoryService(Get.find()),
      fenix: true,
    );
    Get.lazyPut<HistoryController>(
      () => HistoryController(Get.find()),
      fenix: true,
    );
  }
}
