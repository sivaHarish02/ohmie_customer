import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ohmie_customer/auth/models/auth_model.dart';
import 'package:ohmie_customer/core/services/api_service.dart';
import 'package:ohmie_customer/core/services/storage_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString mobile = ''.obs;

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      Get.snackbar(
        'Invalid Number',
        'Please enter a valid 10-digit mobile number.',
        backgroundColor: const Color(0xFF0F3460),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;
    try {
      final fullMobile = '+91$phone';
      await _apiService.post(
        '/customer/auth/send-otp',
        data: {'mobile': fullMobile},
      );
      mobile.value = fullMobile;
      Get.toNamed('/otp');
    } catch (e) {
      _showError('Failed to send OTP', _parseError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the 6-digit OTP sent to your number.',
        backgroundColor: const Color(0xFF0F3460),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiService.post(
        '/customer/auth/verify-otp',
        data: {'mobile': mobile.value, 'otp': otp},
      );

      final responseData = response is Map && response['data'] != null
          ? response['data'] as Map<String, dynamic>
          : response as Map<String, dynamic>;
      final user = UserModel.fromJson(responseData);
      await _storageService.saveToken(user.token);
      await _storageService.saveUser(user.toJson());

      Get.offAllNamed('/home');
    } catch (e) {
      _showError('Verification Failed', _parseError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (mobile.value.isEmpty) return;
    isLoading.value = true;
    try {
      await _apiService.post(
        '/customer/auth/send-otp',
        data: {'mobile': mobile.value},
      );
      Get.snackbar(
        'OTP Sent',
        'A new OTP has been sent to ${mobile.value}.',
        backgroundColor: const Color(0xFF0F3460),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      _showError('Resend Failed', _parseError(e));
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.shade800,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      return e.toString().replaceAll('Exception: ', '');
    }
    return 'Something went wrong. Please try again.';
  }
}
