import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:ohmie_customer/core/constants/app_colors.dart';
import 'package:ohmie_customer/feature/history/models/history_model.dart';
import 'package:ohmie_customer/feature/history/widgets/history_image_preview.dart';

class HistoryJobCard extends StatefulWidget {
  const HistoryJobCard({
    super.key,
    required this.job,
    required this.onRebook,
  });

  final HistoryJob job;
  final VoidCallback onRebook;

  @override
  State<HistoryJobCard> createState() => _HistoryJobCardState();
}

class _HistoryJobCardState extends State<HistoryJobCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _animController;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _expandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _animController.forward() : _animController.reverse();
  }

  Color get _statusColor {
    switch (widget.job.status) {
      case 'COMPLETED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.warning;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  IconData get _categoryIcon {
    final cat = widget.job.categoryName.toLowerCase();
    if (cat.contains('ac')) return Icons.ac_unit_rounded;
    if (cat.contains('washing')) return Icons.local_laundry_service_rounded;
    if (cat.contains('fridge') || cat.contains('refrigerator'))
      return Icons.kitchen_rounded;
    if (cat.contains('ro')) return Icons.water_drop_rounded;
    if (cat.contains('electric')) return Icons.bolt_rounded;
    if (cat.contains('plumb')) return Icons.plumbing_rounded;
    if (cat.contains('geyser')) return Icons.hot_tub_rounded;
    if (cat.contains('tv')) return Icons.tv_rounded;
    return Icons.build_circle_outlined;
  }

  String get _formattedDate =>
      DateFormat('dd MMM yyyy').format(widget.job.createdAt);

  String _duration() {
    final d = widget.job.duration;
    if (d == null) return 'Not Available';
    if (d < 60) return '${d}m';
    return '${d ~/ 60}h ${d % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(18.r),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(_categoryIcon,
                        size: 22.sp, color: AppColors.primary),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.categoryName,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          job.jobCode,
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            _StatusBadge(
                                status: job.status, color: _statusColor),
                            SizedBox(width: 8.w),
                            _PayBadge(paymentStatus: job.paymentStatus),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        job.amount != null
                            ? 'Rs.${job.amount!.toStringAsFixed(0)}'
                            : 'Not Available',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text),
                      ),
                      SizedBox(height: 4.h),
                      Text(_formattedDate,
                          style: TextStyle(
                              fontSize: 10.sp, color: AppColors.textMuted)),
                      SizedBox(height: 6.h),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textMuted, size: 20.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
            child: Row(
              children: [
                Icon(Icons.person_outline_rounded,
                    size: 13.sp, color: AppColors.textMuted),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    job.technician?.name ?? 'Not Assigned',
                    style:
                        TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.location_on_outlined,
                    size: 13.sp, color: AppColors.textMuted),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    job.address ?? 'Not Available',
                    style:
                        TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (job.scopeOfWork.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
              child: Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: job.scopeOfWork
                    .map((s) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ))
                    .toList(),
              ),
            ),
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: AppColors.border, height: 1),
                  SizedBox(height: 12.h),
                  _DetailRow(
                      icon: Icons.location_on_rounded,
                      label: 'Full Address',
                      value: job.address ?? 'Not Available'),
                  SizedBox(height: 8.h),
                  _DetailRow(
                      icon: Icons.payment_rounded,
                      label: 'Payment Method',
                      value: job.paymentMethod ?? 'Not Available'),
                  SizedBox(height: 8.h),
                  _DetailRow(
                      icon: Icons.timer_rounded,
                      label: 'Duration',
                      value: _duration()),
                  if (job.completedAt != null) ...[
                    SizedBox(height: 8.h),
                    _DetailRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Completed At',
                      value: DateFormat('dd MMM yyyy, hh:mm a')
                          .format(job.completedAt!),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                          child: HistoryImagePreview(
                              label: 'Before', filename: job.beforeImage)),
                      SizedBox(width: 10.w),
                      Expanded(
                          child: HistoryImagePreview(
                              label: 'After', filename: job.afterImage)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onRebook,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Book Again'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        minimumSize: Size.fromHeight(44.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 10.sp, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}

class _PayBadge extends StatelessWidget {
  const _PayBadge({this.paymentStatus});
  final String? paymentStatus;

  @override
  Widget build(BuildContext context) {
    final label = paymentStatus ?? 'No payment data';
    Color c = AppColors.textMuted;
    if (label == 'PAID') c = AppColors.success;
    if (label == 'PENDING') c = AppColors.warning;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.primary),
        SizedBox(width: 6.w),
        SizedBox(
          width: 90.w,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.text),
          ),
        ),
      ],
    );
  }
}
