import 'package:get/get.dart';
import 'package:ohmie_customer/feature/home/models/active_job_model.dart';
import 'package:ohmie_customer/feature/home/models/category_model.dart';
import 'package:ohmie_customer/core/services/api_service.dart';
import 'package:ohmie_customer/core/services/socket_service.dart';
import 'package:ohmie_customer/core/services/storage_service.dart';

class HomeController extends GetxController {
  late final ApiService _apiService;
  late final StorageService _storageService;
  late final SocketService _socketService;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final Rxn<ActiveJobModel> activeJob = Rxn<ActiveJobModel>();
  final RxList<Map<String, dynamic>> recentJobs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();
    _storageService = Get.find<StorageService>();
    _socketService = Get.find<SocketService>();

    final user = _storageService.getUser();
    if (user != null) {
      userName.value = (user['name'] ?? '').toString();
    }

    loadData();
    connectSocket();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadCategories(),
        loadActiveJob(),
        loadRecentJobs(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await _apiService.get('/customer/categories');
      List<dynamic>? list;
      if (response is List) {
        list = response;
      } else if (response is Map && response['data'] is List) {
        list = response['data'] as List;
      }
      if (list != null) {
        categories.value = list
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // silently fail; UI will show empty state
    }
  }

  Future<void> loadActiveJob() async {
    try {
      final response = await _apiService.get('/customer/active-job');
      dynamic data;
      if (response is Map && response['data'] != null) {
        data = response['data'];
      } else {
        data = response;
      }
      if (data != null && data is Map<String, dynamic> && data.isNotEmpty) {
        activeJob.value = ActiveJobModel.fromJson(data);
      } else {
        activeJob.value = null;
      }
    } catch (_) {
      activeJob.value = null;
    }
  }

  Future<void> loadRecentJobs() async {
    try {
      final response = await _apiService
          .get('/customer/jobs', queryParameters: {'limit': 3});
      List<dynamic>? list;
      if (response is List) {
        list = response;
      } else if (response is Map && response['data'] is List) {
        list = response['data'] as List;
      }
      if (list != null) {
        recentJobs.value = list.cast<Map<String, dynamic>>();
      } else {
        recentJobs.clear();
      }
    } catch (_) {
      recentJobs.clear();
    }
  }

  void connectSocket() {
    final token = _storageService.getToken();
    if (token == null || token.isEmpty) return;

    _socketService.connect(token);
    _socketService.on('job_updated', (_) {
      loadActiveJob();
    });
  }

  @override
  void onClose() {
    _socketService.off('job_updated');
    super.onClose();
  }
}
