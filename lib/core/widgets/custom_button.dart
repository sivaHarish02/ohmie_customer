import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ohmie_customer/core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.outlined = false,
    this.icon,
    this.textColor,
    this.fontSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;

  /// If true, renders an outlined variant instead of the filled gradient button.
  final bool outlined;

  /// Optional leading icon widget.
  final Widget? icon;

  /// Override text color (defaults to white for filled, orange for outlined).
  final Color? textColor;

  /// Override font size (defaults to 16.sp).
  final double? fontSize;

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return _buildOutlined();
    }
    return _buildFilled();
  }

  // ---------------------------------------------------------------------------
  // Filled gradient button
  // ---------------------------------------------------------------------------

  Widget _buildFilled() {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isDisabled
              ? null
              : const LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.primaryDark,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: _isDisabled ? AppTheme.textDisabled : null,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: _isDisabled
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            minimumSize: Size(width ?? double.infinity, height ?? 52.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
          ),
          child: _buildChild(
            color:
                _isDisabled ? AppTheme.textHint : (textColor ?? Colors.white),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Outlined button
  // ---------------------------------------------------------------------------

  Widget _buildOutlined() {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52.h,
      child: OutlinedButton(
        onPressed: _isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _isDisabled ? AppTheme.textHint : AppTheme.primary,
          side: BorderSide(
            color: _isDisabled ? AppTheme.textDisabled : AppTheme.primary,
            width: 1.5,
          ),
          minimumSize: Size(width ?? double.infinity, height ?? 52.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
        ),
        child: _buildChild(
          color:
              _isDisabled ? AppTheme.textHint : (textColor ?? AppTheme.primary),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared child: loading spinner or label (+ optional icon)
  // ---------------------------------------------------------------------------

  Widget _buildChild({required Color color}) {
    if (isLoading) {
      return SizedBox(
        width: 22.r,
        height: 22.r,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          SizedBox(width: 8.w),
          _labelText(color),
        ],
      );
    }

    return _labelText(color);
  }

  Widget _labelText(Color color) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: fontSize ?? 16.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}
