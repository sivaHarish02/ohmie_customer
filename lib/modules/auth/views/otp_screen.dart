import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ohmie_customer/auth/controllers/auth_controller.dart';

class OtpScreen extends GetView<AuthController> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 32.h),
              _buildHeader(),
              SizedBox(height: 48.h),
              _buildOtpCard(),
              SizedBox(height: 24.h),
              _buildResendSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.sms_rounded,
              color: const Color(0xFFFF6B35),
              size: 34.sp,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'Verify Your Number',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10.h),
        Obx(() {
          final maskedNumber = _maskMobile(controller.mobile.value);
          return Text(
            'We sent a 6-digit OTP to\n$maskedNumber',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white54,
              height: 1.6,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOtpCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOtpField(),
          SizedBox(height: 28.h),
          _buildVerifyButton(),
        ],
      ),
    );
  }

  Widget _buildOtpField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white60,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F3460).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller.otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 26.sp,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 10,
            ),
            decoration: InputDecoration(
              hintText: '------',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontSize: 22.sp,
                letterSpacing: 10,
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 18.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              disabledBackgroundColor:
                  const Color(0xFFFF6B35).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ));
  }

  Widget _buildResendSection() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the OTP? ",
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white54,
              ),
            ),
            GestureDetector(
              onTap: controller.isLoading.value ? null : controller.resendOtp,
              child: Text(
                'Resend',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: controller.isLoading.value
                      ? Colors.white30
                      : const Color(0xFFFF6B35),
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFFFF6B35),
                ),
              ),
            ),
          ],
        ));
  }

  String _maskMobile(String mobile) {
    if (mobile.isEmpty) return '';
    if (mobile.startsWith('+91')) {
      final number = mobile.substring(3);
      if (number.length == 10) {
        return '+91 ${number.substring(0, 2)}XXXXXX${number.substring(8)}';
      }
    }
    if (mobile.length >= 10) {
      return '${mobile.substring(0, 4)}XXXXXX${mobile.substring(mobile.length - 2)}';
    }
    return mobile;
  }
}
