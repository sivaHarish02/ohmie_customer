import 'package:get/get.dart';
import 'package:ohmie_customer/core/services/storage_service.dart';
import 'package:ohmie_customer/feature/home/home_service.dart';

class HomeController extends GetxController {
  HomeController(this._homeService, this._storageService);

  final HomeService _homeService;
  final StorageService _storageService;

  final isLoading = false.obs;
  final activeBooking = Rxn<Map<String, dynamic>>();
  final activeBookings = <Map<String, dynamic>>[].obs;
  final popularServices = <Map<String, dynamic>>[
    {'name': 'AC Service', 'icon': 'snowflake'},
    {'name': 'Washing Machine', 'icon': 'local_laundry_service'},
    {'name': 'Refrigerator', 'icon': 'kitchen'},
    {'name': 'RO Service', 'icon': 'water_drop'},
    {'name': 'Electrical', 'icon': 'bolt'},
    {'name': 'Plumbing', 'icon': 'plumbing'},
  ].obs;
  final recentBookings = <Map<String, dynamic>>[].obs;
  final userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final user = _storageService.getUser();
    userName.value = (user?['name'] ?? 'Customer').toString();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    isLoading.value = true;
    try {
      final summary = await _homeService.getHomeSummary();

      final summaryActive = summary['activeBooking'];
      if (summaryActive is List) {
        final list = summaryActive
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        activeBookings.assignAll(list);
        activeBooking.value = list.isNotEmpty ? list.first : null;
      } else if (summaryActive is Map) {
        final map = Map<String, dynamic>.from(summaryActive);
        activeBooking.value = map;
        activeBookings.assignAll([map]);
      } else {
        final fallback = await _homeService.getActiveBooking();
        activeBooking.value = fallback;
        activeBookings.assignAll(fallback == null ? [] : [fallback]);
      }

      final summaryRecent = summary['recentBookings'];
      if (summaryRecent is List) {
        recentBookings.assignAll(
          summaryRecent
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .take(3)
              .toList(),
        );
      } else {
        recentBookings.assignAll(
          (await _homeService.getRecentBookings(limit: 3)).take(3).toList(),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
