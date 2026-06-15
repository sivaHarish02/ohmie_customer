import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ohmie_customer/core/constants/app_colors.dart';
import 'package:ohmie_customer/core/routes/app_routes.dart';
import 'package:ohmie_customer/feature/profile/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  Future<void> _openEditProfileDialog() async {
    final emailController = TextEditingController(text: controller.email);
    final avatarController = TextEditingController(text: controller.avatarUrl);

    await Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'name@example.com',
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: avatarController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Avatar URL',
                  hintText: 'https://...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.updateProfile(
                email: emailController.text,
                avatarUrl: avatarController.text,
              );
              if (!controller.isLoading.value) {
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout from this account?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await controller.logout();
    }
  }

  void _copyMobile() {
    final mobile = controller.mobile;
    if (mobile.isEmpty) return;
    Clipboard.setData(ClipboardData(text: mobile));
    Get.snackbar('Copied', 'Mobile number copied to clipboard');
  }

  Widget _sectionTitle(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
        leading: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: 18.sp,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textMuted,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            onPressed: controller.refreshProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value && controller.user.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshProfile,
            color: AppColors.primary,
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30.r,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          backgroundImage: controller.hasAvatarUrl
                              ? NetworkImage(controller.avatarUrl)
                              : null,
                          child: controller.hasAvatarUrl
                              ? null
                              : Text(
                                  controller.avatarInitial,
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.name,
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                controller.mobile,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              if (controller.email.isNotEmpty) ...[
                                SizedBox(height: 3.h),
                                Text(
                                  controller.email,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                              SizedBox(height: 4.h),
                              Text(
                                controller.memberSince,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _copyMobile,
                          icon: const Icon(Icons.copy_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                _sectionTitle('Quick Actions'),
                _actionTile(
                  icon: Icons.edit_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Update email and avatar',
                  onTap: _openEditProfileDialog,
                ),
                SizedBox(height: 8.h),
                _actionTile(
                  icon: Icons.history_rounded,
                  title: 'Booking History',
                  subtitle: 'View your previous service jobs',
                  onTap: () => Get.toNamed(AppRoutes.history),
                ),
                SizedBox(height: 8.h),
                _actionTile(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'New Booking',
                  subtitle: 'Book a new service quickly',
                  onTap: () => Get.toNamed(AppRoutes.home),
                ),
                SizedBox(height: 8.h),
                _actionTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Help and Support',
                  subtitle: 'Reach support for booking assistance',
                  onTap: () {
                    Get.snackbar(
                      'Support',
                      'Support center will be available soon.',
                    );
                  },
                ),
                SizedBox(height: 14.h),
                _sectionTitle('Account Details'),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      children: [
                        _infoRow('Name', controller.name),
                        SizedBox(height: 10.h),
                        _infoRow('Mobile', controller.mobile),
                        SizedBox(height: 10.h),
                        _infoRow(
                          'Email',
                          controller.email.isEmpty
                              ? 'Not added'
                              : controller.email,
                        ),
                        SizedBox(height: 10.h),
                        _infoRow('Status', 'Active',
                            valueColor: AppColors.success),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: _confirmLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}
