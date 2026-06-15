import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ohmie_customer/core/constants/app_colors.dart';
import 'package:ohmie_customer/core/routes/app_routes.dart';
import 'package:ohmie_customer/feature/home/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.loadHomeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 18.h),
              _buildMainBookingCta(),
              SizedBox(height: 16.h),
              if (controller.activeBookings.isNotEmpty) ...[
                _sectionTitle('Active Service'),
                _buildActiveServiceCards(),
                SizedBox(height: 16.h),
              ],
              _sectionTitle('Popular Services'),
              SizedBox(height: 10.h),
              _buildPopularServices(),
              SizedBox(height: 16.h),
              _sectionTitle('Why Customers Trust Ohmie'),
              SizedBox(height: 10.h),
              _buildTrustSection(),
              SizedBox(height: 16.h),
              _sectionTitle('Recent Bookings'),
              SizedBox(height: 10.h),
              if (controller.isLoading.value &&
                  controller.recentBookings.isEmpty)
                _buildLoadingSkeleton()
              else if (controller.recentBookings.isEmpty)
                _emptyState('No recent bookings yet')
              else
                _buildRecentBookings(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveServiceCards() {
    if (controller.activeBookings.length == 1) {
      return _buildActiveServiceCard(controller.activeBookings.first);
    }

    return SizedBox(
      height: 250.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.activeBookings.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          return SizedBox(
            width: Get.width - 42.w,
            child: _buildActiveServiceCard(controller.activeBookings[index]),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${controller.userName.value.isEmpty ? 'Customer' : controller.userName.value} 👋',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'What service do you need today?',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        _iconBubble(
          icon: Icons.notifications_none_rounded,
          onTap: () => Get.snackbar('Notifications', 'No new notifications.'),
        ),
        SizedBox(width: 8.w),
        _iconBubble(
          icon: Icons.person_outline_rounded,
          onTap: () => Get.toNamed(AppRoutes.profile),
        ),
      ],
    );
  }

  Widget _iconBubble({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: AppColors.text),
      ),
    );
  }

  Widget _buildMainBookingCta() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.96, end: 1),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: _GlassCard(
        borderRadius: 24.r,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.30),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book a Service',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'AC, Washing Machine, RO, Refrigerator & more',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: 140.w,
                height: 46.h,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.booking),
                  child: Text(
                    'Book Now',
                    style:
                        TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveServiceCard(Map<String, dynamic> active) {
    final serviceName =
        (active['serviceName'] ?? active['categoryName'] ?? 'Service')
            .toString();
    final status = (active['status'] ?? 'PENDING').toString();
    final scheduleRaw =
        (active['scheduleTime'] ?? active['date'] ?? '').toString();
    final address = (active['address'] ?? '').toString();
    final jobId = active['id']?.toString();
    final statusColor = _statusColor(status);

    return _GlassCard(
      borderRadius: 20.r,
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.miscellaneous_services_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Service',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                _statusBadge(status),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _formatDate(scheduleRaw),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (address.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
              ),
            ],
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton.icon(
                onPressed: jobId == null
                    ? null
                    : () => Get.toNamed(
                          AppRoutes.tracking,
                          arguments: {'jobId': jobId},
                        ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: Icon(Icons.location_searching_rounded, size: 17.sp),
                label: Text(
                  'Track Service',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return AppColors.success;
      case 'REJECTED':
      case 'CLOSED':
        return AppColors.error;
      case 'WAITING_OTP':
      case 'WAITING_APPROVAL':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildPopularServices() {
    return SizedBox(
      height: 130.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.popularServices.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final item = controller.popularServices[index];
          return GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.booking, arguments: item),
            child: _GlassCard(
              borderRadius: 18.r,
              child: Container(
                width: 118.w,
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _serviceIcon((item['icon'] ?? '').toString()),
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      (item['name'] ?? 'Service').toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _serviceIcon(String key) {
    switch (key) {
      case 'snowflake':
        return Icons.ac_unit_rounded;
      case 'local_laundry_service':
        return Icons.local_laundry_service_rounded;
      case 'kitchen':
        return Icons.kitchen_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      default:
        return Icons.build_circle_outlined;
    }
  }

  Widget _buildTrustSection() {
    const trustItems = [
      {'title': 'Verified Technicians', 'icon': Icons.verified_user_rounded},
      {'title': 'Secure Payments', 'icon': Icons.security_rounded},
      {'title': 'Service Warranty', 'icon': Icons.workspace_premium_rounded},
      {'title': 'Fast Support', 'icon': Icons.support_agent_rounded},
    ];

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: trustItems.map((item) {
        return _GlassCard(
          borderRadius: 14.r,
          child: SizedBox(
            width: (Get.width - 42.w) / 2,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      (item['title'] ?? '').toString(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentBookings() {
    return Column(
      children: controller.recentBookings.take(3).map((booking) {
        final service =
            (booking['serviceName'] ?? booking['categoryName'] ?? 'Service')
                .toString();
        final date = (booking['date'] ?? booking['createdAt'] ?? '').toString();
        final status = (booking['status'] ?? 'PENDING').toString();
        final amount = booking['amount'] ?? booking['totalAmount'] ?? '-';

        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _GlassCard(
            borderRadius: 16.r,
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              title: Text(
                service,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              subtitle: Text(
                _formatDate(date),
                style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. $amount',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _statusBadge(status),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _GlassCard(
            borderRadius: 16.r,
            child: SizedBox(height: 76.h),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String text) {
    return _GlassCard(
      borderRadius: 16.r,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(Icons.inbox_rounded, color: AppColors.textMuted, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'Scheduled soon';
    return DateFormat('dd MMM, hh:mm a').format(dt);
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    required this.borderRadius,
  });

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
