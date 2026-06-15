import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ohmie_customer/core/constants/app_colors.dart';

class TechnicianInfoCard extends StatelessWidget {
  const TechnicianInfoCard({super.key, this.technician});

  final Map<String, dynamic>? technician;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
      ),
      child: technician == null
          ? Text(
              'Technician will be assigned soon',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.13),
                  child: const Icon(Icons.verified_user_rounded,
                      color: AppColors.primary),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (technician!['name'] ?? 'Technician').toString(),
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Rating: ${(technician!['rating'] ?? 'N/A').toString()}',
                        style: TextStyle(
                            fontSize: 12.sp, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Get.snackbar('Support',
                        'Our support team will connect you shortly.');
                  },
                  icon: const Icon(Icons.support_agent_rounded),
                  label: const Text('Support'),
                ),
              ],
            ),
    );
  }
}
