import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ohmie_customer/core/constants/app_colors.dart';
import 'package:ohmie_customer/core/constants/app_constants.dart';
import 'package:ohmie_customer/feature/tracking/controllers/tracking_controller.dart';

class TrackingScreen extends GetView<TrackingController> {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _backgroundArt(),
          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value && controller.job.value == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final job = controller.job.value;
              if (job == null) {
                return _emptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.loadJob,
                color: AppColors.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _header(job.id)),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _statusPanel(),
                          SizedBox(height: 12.h),
                          _jobOverviewPanel(),
                          SizedBox(height: 12.h),
                          _timelinePanel(),
                          SizedBox(height: 12.h),
                          if (controller.showTechnicianCard) ...[
                            _technicianPanel(),
                            SizedBox(height: 12.h),
                          ],
                          _paymentPanel(),
                          SizedBox(height: 24.h),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _backgroundArt() {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFFEAF2),
                  const Color(0xFFFDFBFC),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -90.h,
          right: -70.w,
          child: _orb(const Color(0x33ED155D), 210.w),
        ),
        Positioned(
          top: 220.h,
          left: -80.w,
          child: _orb(const Color(0x22F39C12), 190.w),
        ),
        Positioned(
          bottom: -90.h,
          right: 30.w,
          child: _orb(const Color(0x22ED155D), 180.w),
        ),
      ],
    );
  }

  Widget _orb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 70,
            spreadRadius: 16,
          ),
        ],
      ),
    );
  }

  Widget _header(String id) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.text,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Tracking',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Job #$id',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.loadJob,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _statusPanel() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: controller.statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  controller.statusLabel,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.electric_bolt_rounded,
                color: controller.statusColor,
                size: 18.sp,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: controller.statusProgress,
              minHeight: 8.h,
              backgroundColor: Colors.black.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(controller.statusColor),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Tracking updates are synced in real-time.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _jobOverviewPanel() {
    final job = controller.job.value!;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelTitle('Service Overview'),
          SizedBox(height: 10.h),
          _dataRow('Category', job.categoryName),
          _dataRow('Scheduled', _fmtDate(job.scheduledTime)),
          _dataRow('Address', job.address),
          _dataRow(
              'Description', job.description.isEmpty ? '-' : job.description),
        ],
      ),
    );
  }

  Widget _timelinePanel() {
    final steps = <String>[
      AppConstants.jobStatusCreated,
      AppConstants.jobStatusAssigned,
      AppConstants.jobStatusAccepted,
      AppConstants.jobStatusInProgress,
      AppConstants.jobStatusWaitingOtp,
      AppConstants.jobStatusCompleted,
    ];

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelTitle('Progress Timeline'),
          SizedBox(height: 12.h),
          ...steps.map((status) {
            final reached = controller.isStatusReached(status);
            final isCurrent = controller.isStatusCurrent(status);
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: reached
                          ? (isCurrent ? AppColors.primary : AppColors.success)
                          : Colors.black.withValues(alpha: 0.08),
                      border: Border.all(
                        color: reached ? Colors.white : AppColors.border,
                      ),
                    ),
                    child: reached
                        ? Icon(
                            isCurrent
                                ? Icons.radio_button_checked_rounded
                                : Icons.check_rounded,
                            size: 12.sp,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      controller.statusStepLabel(status),
                      style: TextStyle(
                        color: reached ? AppColors.text : AppColors.textMuted,
                        fontSize: 13.sp,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _technicianPanel() {
    final job = controller.job.value!;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelTitle('Technician'),
          SizedBox(height: 10.h),
          Text(
            job.technicianName ?? 'Technician not assigned yet',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            job.technicianPhone ?? 'Phone number unavailable',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _callNow(job.technicianPhone),
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                        'Support', 'Support team will contact you soon.');
                  },
                  icon: const Icon(Icons.support_agent_rounded),
                  label: const Text('Support'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentPanel() {
    final job = controller.job.value!;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelTitle('Payment Summary'),
          SizedBox(height: 10.h),
          _dataRow(
            'Amount',
            job.amount == null
                ? 'Will be updated'
                : 'Rs. ${job.amount!.toStringAsFixed(0)}',
          ),
          _dataRow('Status', job.paymentStatus),
          if (controller.showPaymentButton) ...[
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.snackbar('Payment', 'Payment flow will open here.');
                },
                icon: const Icon(Icons.payments_rounded),
                label: const Text('Pay Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: _GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.track_changes_rounded,
                  color: AppColors.textMuted, size: 54.sp),
              SizedBox(height: 10.h),
              Text(
                'No tracking data available',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Pull to refresh or check your booking history.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.text,
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _dataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84.w,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  Future<void> _callNow(String? rawPhone) async {
    if (rawPhone == null || rawPhone.trim().isEmpty) {
      Get.snackbar('Unavailable', 'Technician phone number is not available.');
      return;
    }

    final cleaned = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    Get.snackbar('Call Failed', 'Could not open dialer on this device.');
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
