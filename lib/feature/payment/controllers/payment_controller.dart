import 'package:get/get.dart';
import 'package:ohmie_customer/core/services/api_service.dart';
import 'package:ohmie_customer/feature/payment/models/payment_model.dart';

class PaymentController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  late final RxString jobId;
  final Rxn<PaymentInfo> paymentInfo = Rxn<PaymentInfo>();
  final Rx<PaymentMethod> selectedMethod =
      Rx<PaymentMethod>(PaymentMethod.cash);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    jobId = RxString(args['jobId'] as String? ?? '');
    loadPaymentInfo();
  }

  Future<void> loadPaymentInfo() async {
    if (jobId.value.isEmpty) return;
    isLoading.value = true;
    try {
      final response =
          await _apiService.get('/customer/jobs/${jobId.value}/payment');
      if (response != null) {
        final data = (response is Map && response['data'] is Map)
            ? response['data'] as Map<String, dynamic>
            : response as Map<String, dynamic>;
        paymentInfo.value = PaymentInfo.fromJson(data);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payment info. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmPayment() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final method =
          selectedMethod.value == PaymentMethod.cash ? 'CASH' : 'ONLINE';
      await _apiService.post(
        '/customer/jobs/${jobId.value}/payment',
        data: {'method': method},
      );
      Get.offAllNamed('/home');
      Get.snackbar(
        'Payment Confirmed',
        'Your payment has been confirmed successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to confirm payment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
