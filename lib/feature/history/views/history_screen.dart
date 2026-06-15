import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ohmie_customer/core/constants/app_colors.dart';
import 'package:ohmie_customer/feature/history/controllers/history_controller.dart';
import 'package:ohmie_customer/feature/history/widgets/history_empty_widget.dart';
import 'package:ohmie_customer/feature/history/widgets/history_filter_chips.dart';
import 'package:ohmie_customer/feature/history/widgets/history_job_card.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _appBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.refreshHistory,
                    color: AppColors.primary,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                        SliverToBoxAdapter(child: _summaryCards()),
                        SliverToBoxAdapter(child: SizedBox(height: 14.h)),
                        const SliverToBoxAdapter(child: HistoryFilterChips()),
                        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                        SliverToBoxAdapter(child: _searchBar()),
                        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                        _jobList(),
                        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Background gradient ──────────────────────────────────────────────────
  Widget _background() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFEAF2),
            Color(0xFFFDFBFC),
            AppColors.background,
          ],
        ),
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────
  Widget _appBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16.sp, color: AppColors.text),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service History',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  'Your past service bookings',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => GestureDetector(
                onTap: controller.refreshHistory,
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: controller.isLoading.value
                      ? Padding(
                          padding: EdgeInsets.all(10.w),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(Icons.refresh_rounded,
                          size: 18.sp, color: AppColors.text),
                ),
              )),
        ],
      ),
    );
  }

  // ── Summary cards ────────────────────────────────────────────────────────
  Widget _summaryCards() {
    return Obx(() {
      final total = controller.totalJobs.value;
      final completed = controller.completedCount;
      final cancelled = controller.cancelledCount;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
                child: _SummaryCard(
                    label: 'Total', value: total, color: AppColors.primary)),
            SizedBox(width: 8.w),
            Expanded(
                child: _SummaryCard(
                    label: 'Completed',
                    value: completed,
                    color: AppColors.success)),
            SizedBox(width: 8.w),
            Expanded(
                child: _SummaryCard(
                    label: 'Cancelled',
                    value: cancelled,
                    color: AppColors.warning)),
          ],
        ),
      );
    });
  }

  // ── Search bar ───────────────────────────────────────────────────────────
  Widget _searchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TextField(
        controller: controller.searchController,
        onSubmitted: (_) => controller.searchHistory(),
        textInputAction: TextInputAction.search,
        style: TextStyle(fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: 'Search job code, category or address...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.searchController,
            builder: (_, value, __) => value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      controller.searchController.clear();
                      controller.searchHistory();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.8),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Job list sliver ──────────────────────────────────────────────────────
  Widget _jobList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _SkeletonCard(),
            childCount: 4,
          ),
        );
      }

      if (controller.hasError.value) {
        return SliverToBoxAdapter(child: _errorState());
      }

      final jobs = controller.historyJobs;

      if (jobs.isEmpty) {
        return const SliverFillRemaining(child: HistoryEmptyWidget());
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == jobs.length) {
              return _paginationFooter();
            }
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: HistoryJobCard(
                job: jobs[index],
                onRebook: () => controller.rebookService(jobs[index]),
              ),
            );
          },
          childCount: jobs.length + 1,
        ),
      );
    });
  }

  Widget _paginationFooter() {
    return Obx(() {
      if (controller.isPaginating.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      }
      if (controller.hasMore) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
          child: TextButton.icon(
            onPressed: controller.loadMore,
            icon: const Icon(Icons.expand_more_rounded),
            label: const Text('Load more'),
          ),
        );
      }
      return SizedBox(height: 4.h);
    });
  }

  Widget _errorState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48.sp),
          SizedBox(height: 12.h),
          Text(
            'Could not load history',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.text),
          ),
          SizedBox(height: 6.h),
          Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
          ),
          SizedBox(height: 16.h),
          OutlinedButton.icon(
            onPressed: controller.refreshHistory,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ── Summary card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton loading card ─────────────────────────────────────────────────────
class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      height: 100.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _shimmer(width: 140.w, height: 12.h),
                  SizedBox(height: 6.h),
                  _shimmer(width: 80.w, height: 10.h),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _shimmer(width: 60.w, height: 18.h),
                      SizedBox(width: 8.w),
                      _shimmer(width: 50.w, height: 18.h),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}
