import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ohmie_customer/feature/payment/controllers/payment_controller.dart';
import 'package:ohmie_customer/feature/payment/models/payment_model.dart';

class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({super.key});

  static const Color _primary = Color(0xFFFF6B35);
  static const Color _bg = Color(0xFF1A1A2E);
  static const Color _surface = Color(0xFF16213E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Payment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.paymentInfo.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TotalAmountCard(controller: controller),
                    SizedBox(height: 24.h),
                    Text(
                      'Select Payment Method',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _PaymentMethodCard(
                      method: PaymentMethod.cash,
                      controller: controller,
                    ),
                    SizedBox(height: 12.h),
                    _PaymentMethodCard(
                      method: PaymentMethod.online,
                      controller: controller,
                    ),
                  ],
                ),
              ),
            ),
            _ConfirmButton(controller: controller),
          ],
        );
      }),
    );
  }
}

class _TotalAmountCard extends StatelessWidget {
  final PaymentController controller;

  const _TotalAmountCard({required this.controller});

  static const Color _surface = Color(0xFF16213E);
  static const Color _card = Color(0xFF0F3460);
  static const Color _primary = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_surface, _card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Total Amount',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            final amount = controller.paymentInfo.value?.totalAmount ?? 0.0;
            return Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: _primary,
                fontSize: 40.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final PaymentController controller;

  const _PaymentMethodCard({
    required this.method,
    required this.controller,
  });

  static const Color _primary = Color(0xFFFF6B35);
  static const Color _card = Color(0xFF0F3460);

  @override
  Widget build(BuildContext context) {
    final isCash = method == PaymentMethod.cash;

    return Obx(() {
      final isSelected = controller.selectedMethod.value == method;
      return GestureDetector(
        onTap: () => controller.selectedMethod.value = method,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected ? _primary.withValues(alpha: 0.1) : _card,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? _primary : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _primary.withValues(alpha: 0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      isCash ? Icons.payments_outlined : Icons.qr_code_2,
                      color: isSelected ? _primary : Colors.white54,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      isCash ? 'Cash' : 'Online Payment',
                      style: TextStyle(
                        color: isSelected ? _primary : Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? _primary : Colors.white38,
                        width: 2,
                      ),
                      color: isSelected ? _primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 12.sp)
                        : null,
                  ),
                ],
              ),
              if (!isCash && isSelected) ...[
                SizedBox(height: 16.h),
                _OnlinePaymentDetails(controller: controller),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _OnlinePaymentDetails extends StatelessWidget {
  final PaymentController controller;

  const _OnlinePaymentDetails({required this.controller});

  static const Color _primary = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    final info = controller.paymentInfo.value;
    if (info == null) {
      return const Center(
        child: CircularProgressIndicator(color: _primary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (info.qrCodeUrl != null && info.qrCodeUrl!.isNotEmpty) ...[
          Center(
            child: Container(
              width: 180.w,
              height: 180.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(8.w),
              child: CachedNetworkImage(
                imageUrl: info.qrCodeUrl!,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: _primary),
                ),
                errorWidget: (context, url, error) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_2,
                        color: Colors.black54, size: 48),
                    SizedBox(height: 8.h),
                    Text(
                      'QR not available',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        if (info.upiId != null && info.upiId!.isNotEmpty) ...[
          _InfoRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'UPI ID',
            value: info.upiId!,
          ),
          SizedBox(height: 8.h),
        ],
        if (info.upiMobile != null && info.upiMobile!.isNotEmpty)
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Mobile',
            value: info.upiMobile!,
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color _primary = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _primary, size: 16.sp),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 13.sp,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final PaymentController controller;

  const _ConfirmButton({required this.controller});

  static const Color _primary = Color(0xFFFF6B35);
  static const Color _bg = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      child: Obx(() {
        final loading = controller.isLoading.value;
        return SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: loading ? null : controller.confirmPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: _primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            child: loading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Confirm Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}
