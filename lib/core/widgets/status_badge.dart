import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _colorForStatus(String s) {
    switch (s.toUpperCase()) {
      case 'CREATED':
        return Colors.grey;
      case 'ASSIGNED':
        return const Color(0xFF1565C0); // blue
      case 'ACCEPTED':
        return const Color(0xFFFF6B35); // orange
      case 'IN_PROGRESS':
        return const Color(0xFF283593); // indigo
      case 'WAITING_APPROVAL':
        return const Color(0xFF6A1B9A); // purple
      case 'WAITING_OTP':
        return const Color(0xFFBF360C); // deep orange
      case 'COMPLETED':
        return const Color(0xFF2E7D32); // green
      case 'CLOSED':
        return const Color(0xFF00695C); // teal
      case 'REJECTED':
        return const Color(0xFFC62828); // red
      default:
        return Colors.grey;
    }
  }

  String _labelForStatus(String s) {
    switch (s.toUpperCase()) {
      case 'CREATED':
        return 'Booking Submitted';
      case 'ASSIGNED':
        return 'Assigned';
      case 'ACCEPTED':
        return 'On the Way';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'WAITING_APPROVAL':
        return 'Awaiting Approval';
      case 'WAITING_OTP':
        return 'Share OTP';
      case 'COMPLETED':
        return 'Completed';
      case 'CLOSED':
        return 'Closed';
      case 'REJECTED':
        return 'Rejected';
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _labelForStatus(status),
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
