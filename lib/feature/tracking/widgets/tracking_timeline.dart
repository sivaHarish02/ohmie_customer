import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ohmie_customer/core/constants/app_colors.dart';

class TrackingTimeline extends StatelessWidget {
  const TrackingTimeline({super.key, required this.timeline});

  final List<Map<String, dynamic>> timeline;

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) {
      return Text(
        'Timeline not available',
        style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
      );
    }

    return Column(
      children: timeline.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final title = (item['title'] ?? '').toString();
        final state = (item['status'] ?? 'PENDING').toString();
        final timeRaw = (item['time'] ?? '').toString();
        final isLast = index == timeline.length - 1;

        final dotColor = state == 'DONE'
            ? AppColors.success
            : state == 'CURRENT'
                ? AppColors.primary
                : AppColors.border;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 18.w,
              child: Column(
                children: [
                  Container(
                    width: 11.w,
                    height: 11.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2.w,
                      height: 34.h,
                      margin: EdgeInsets.symmetric(vertical: 2.h),
                      color: AppColors.border,
                    ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatTime(timeRaw),
                      style: TextStyle(
                          fontSize: 11.sp, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatTime(String raw) {
    if (raw.isEmpty || raw == 'null') return 'Pending';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'Pending';
    return DateFormat('dd MMM, hh:mm a').format(dt);
  }
}
