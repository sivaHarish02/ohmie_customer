import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ohmie_customer/core/constants/app_colors.dart';
import 'package:ohmie_customer/feature/auth/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 56.h),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.electrical_services_rounded,
                      size: 62.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Ohmie Customer',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48.h),
              Text(
                'Mobile Number',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.text,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.phone_rounded,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    prefixText: '+91 ',
                    hintText: 'Enter mobile number',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14.sp,
                    ),
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 14.w,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading.value ? null : controller.sendOtp,
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
                            'Send OTP',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Center(
                child: Text(
                  'We will send a verification code to your number.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
