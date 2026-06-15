import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ohmie_customer/core/routes/app_routes.dart';
import 'package:ohmie_customer/core/services/storage_service.dart';
import 'package:ohmie_customer/feature/auth/auth_service.dart';

class AuthController extends GetxController {
  AuthController(this._authService, this._storageService);

  final AuthService _authService;
  final StorageService _storageService;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final isLoading = false.obs;
  final mobile = ''.obs;

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.length != 10) {
      _showError('Invalid mobile number');
      return;
    }

    isLoading.value = true;
    try {
      mobile.value = phone;
      await _authService.sendOtp(mobile.value);
      Get.toNamed(AppRoutes.otp);
    } catch (_) {
      _showError('Unable to send OTP. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.length != 6 || mobile.value.isEmpty) {
      _showError('Invalid OTP');
      return;
    }

    isLoading.value = true;
    try {
      final response =
          await _authService.verifyOtp(mobile: mobile.value, otp: otp);
      final token = response['token']?.toString() ?? '';
      if (token.isEmpty) {
        _showError('Token missing in response');
        return;
      }

      await _storageService.saveToken(token);
      await _storageService.saveUser(response);
      Get.offAllNamed(AppRoutes.home);
    } catch (_) {
      _showError('OTP verification failed');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
