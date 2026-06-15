import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ohmie_customer/core/constants/app_colors.dart';

class PaymentStatusCard extends StatelessWidget {
  const PaymentStatusCard({
    super.key,
    required this.amount,
    required this.status,
    required this.method,
  });

  final dynamic amount;
  final String status;
  final String? method;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.h),
          _row('Amount', amount == null ? 'No amount added' : 'Rs. $amount'),
          SizedBox(height: 6.h),
          _row('Status', status, valueColor: color),
          SizedBox(height: 6.h),
          _row('Method',
              (method == null || method!.isEmpty) ? 'Pending' : method!),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.text),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PAID':
        return AppColors.success;
      case 'FAILED':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }
}
