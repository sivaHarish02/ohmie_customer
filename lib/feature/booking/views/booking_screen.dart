import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:ohmie_customer/core/constants/app_colors.dart';
import 'package:ohmie_customer/feature/booking/controllers/booking_controller.dart';
import 'package:ohmie_customer/feature/booking/models/booking_model.dart';

class BookingScreen extends GetView<BookingController> {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book a Service'),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
          child: Obx(
            () => SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.submitBooking,
                child: controller.isSubmitting.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Confirm Booking'),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.refreshData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 90.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell us what you need, we\'ll handle the rest',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _stepHeader(),
                    SizedBox(height: 14.h),
                    _sectionCategory(),
                    SizedBox(height: 12.h),
                    _sectionIssueDetails(),
                    SizedBox(height: 12.h),
                    _sectionDateTime(),
                    SizedBox(height: 12.h),
                    _sectionLocation(),
                    SizedBox(height: 12.h),
                    _sectionIssuePhoto(),
                    SizedBox(height: 12.h),
                    _sectionSummary(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _stepHeader() {
    return Obx(() {
      final step = controller.currentStep.value;
      final progress = step / 5;
      return _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step $step of 5',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8.h,
                backgroundColor: Colors.black.withValues(alpha: 0.08),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _sectionCategory() {
    return _glassCard(
      child: Obx(() {
        final items = controller.filteredCategories;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('1. Service Category'),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.categorySearchController,
              decoration: const InputDecoration(
                hintText: 'Search category',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            SizedBox(height: 10.h),
            if (controller.isLoading.value)
              const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
            else
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: items.map(_categoryChip).toList(),
              ),
          ],
        );
      }),
    );
  }

  Widget _categoryChip(BookingCategory category) {
    return Obx(() {
      final selected = controller.selectedCategory.value?.id == category.id;
      return GestureDetector(
        onTap: () => controller.selectCategory(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _categoryIcon(category.name),
                size: 16.sp,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
              SizedBox(width: 6.w),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              if (selected) ...[
                SizedBox(width: 6.w),
                Icon(Icons.check_circle_rounded,
                    size: 16.sp, color: AppColors.primary),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _sectionIssueDetails() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('2. Issue Details'),
          SizedBox(height: 8.h),
          Obx(
            () => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.quickIssueChips.map((chip) {
                final selected = controller.selectedProblemChip.value == chip;
                return ChoiceChip(
                  selected: selected,
                  label: Text(chip),
                  onSelected: (_) => controller.selectProblemChip(chip),
                  selectedColor: AppColors.primary.withValues(alpha: 0.16),
                  labelStyle: TextStyle(
                    color: AppColors.text,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: controller.problemTitleController,
            onChanged: (_) => controller.onIssueTextChanged(),
            decoration: const InputDecoration(
              labelText: 'Problem title*',
              hintText: 'e.g. AC not cooling',
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: controller.descriptionController,
            onChanged: (_) => controller.onIssueTextChanged(),
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Detailed description (optional)',
              hintText: 'Add more details to help technician prepare',
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionDateTime() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('3. Preferred Date & Time'),
          SizedBox(height: 8.h),
          Obx(() {
            final preset = controller.selectedDatePreset.value;
            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _datePresetChip('Today', 'today', preset == 'today'),
                _datePresetChip('Tomorrow', 'tomorrow', preset == 'tomorrow'),
                ActionChip(
                  label: const Text('Custom date'),
                  onPressed: controller.pickDate,
                  side: BorderSide(
                    color: preset == 'custom'
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  backgroundColor: preset == 'custom'
                      ? AppColors.primary.withValues(alpha: 0.16)
                      : Colors.white,
                ),
              ],
            );
          }),
          SizedBox(height: 10.h),
          Obx(
            () => Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                DateFormat('EEE, dd MMM yyyy')
                    .format(controller.selectedDate.value),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Obx(
            () => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.timeSlots.map((slot) {
                final label = slot['label'] as String;
                final selected = controller.selectedTimeSlot.value == label;
                return ChoiceChip(
                  selected: selected,
                  label: Text(label),
                  onSelected: (_) => controller.selectTimeSlot(label),
                  selectedColor: AppColors.primary.withValues(alpha: 0.16),
                  labelStyle: TextStyle(
                    color: AppColors.text,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePresetChip(String label, String value, bool selected) {
    return ActionChip(
      label: Text(label),
      onPressed: () => controller.pickDatePreset(value),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
      backgroundColor:
          selected ? AppColors.primary.withValues(alpha: 0.16) : Colors.white,
    );
  }

  Widget _sectionLocation() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('4. Location Required'),
          SizedBox(height: 4.h),
          Text(
            'Share exact service address for faster technician assignment',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Obx(
            () {
              final hasLocation = controller.hasLocation;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 9.h,
                    ),
                    decoration: BoxDecoration(
                      color: hasLocation
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : const Color(0xFFFFF5D9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: hasLocation
                            ? AppColors.primary.withValues(alpha: 0.38)
                            : const Color(0xFFFFD791),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasLocation
                              ? Icons.verified_rounded
                              : Icons.info_outline_rounded,
                          size: 16.sp,
                          color: hasLocation
                              ? AppColors.primary
                              : const Color(0xFFA55A00),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            hasLocation
                                ? 'Location confirmed and ready for booking'
                                : 'Choose your location from GPS or map pin',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: hasLocation
                                  ? AppColors.primary
                                  : const Color(0xFF7A4100),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.isLocating
                              ? null
                              : controller.getCurrentLocation,
                          icon: controller.isLocating
                              ? SizedBox(
                                  width: 14.w,
                                  height: 14.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.my_location_rounded),
                          label: Text(
                            controller.isLocating
                                ? 'Detecting...'
                                : 'Use Current',
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.openMapPicker,
                          icon: const Icon(Icons.map_rounded),
                          label: const Text('Select on Map'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 10.h),
          Obx(
            () {
              final hasLocation = controller.hasLocation;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: hasLocation ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: hasLocation
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.pin_drop_outlined,
                            size: 16.sp,
                            color: hasLocation
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              hasLocation
                                  ? 'Lat ${controller.latitude.value!.toStringAsFixed(5)} | Lng ${controller.longitude.value!.toStringAsFixed(5)}'
                                  : 'No coordinates selected yet',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: hasLocation
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: controller.addressController,
                      onChanged: (_) => controller.onAddressChanged(),
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Address*',
                        hintText: 'House / Flat / Landmark / Street',
                        prefixIcon: Icon(Icons.home_work_outlined),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionIssuePhoto() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('5. Optional Issue Photo'),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.pickImage(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final image = controller.selectedImage.value;
            if (image == null) {
              return Text(
                'No image selected',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
              );
            }

            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    File(image.path),
                    width: double.infinity,
                    height: 150.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 8.w,
                  top: 8.h,
                  child: GestureDetector(
                    onTap: controller.removeImage,
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _sectionSummary() {
    return _glassCard(
      child: Obx(() {
        final category = controller.selectedCategory.value;
        final preferred = controller.preferredDateTime;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('Summary Before Submit'),
            SizedBox(height: 8.h),
            _summaryRow('Category', category?.name ?? 'Not selected'),
            _summaryRow(
              'Problem',
              controller.problemTitleController.text.trim().isEmpty
                  ? '-'
                  : controller.problemTitleController.text.trim(),
            ),
            _summaryRow(
              'Preferred time',
              preferred == null
                  ? 'Not selected'
                  : DateFormat('dd MMM yyyy, hh:mm a').format(preferred),
            ),
            _summaryRow(
              'Address',
              controller.addressController.text.trim().isEmpty
                  ? 'Not selected'
                  : controller.addressController.text.trim(),
            ),
            _summaryRow(
              'Image',
              controller.selectedImage.value == null
                  ? 'Not attached'
                  : 'Attached',
            ),
          ],
        );
      }),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  IconData _categoryIcon(String name) {
    final key = name.toLowerCase();
    if (key.contains('ac')) return Icons.ac_unit_rounded;
    if (key.contains('washing')) return Icons.local_laundry_service_rounded;
    if (key.contains('refrigerator') || key.contains('fridge')) {
      return Icons.kitchen_rounded;
    }
    if (key.contains('ro')) return Icons.water_drop_rounded;
    if (key.contains('electrical')) return Icons.bolt_rounded;
    if (key.contains('plumbing')) return Icons.plumbing_rounded;
    if (key.contains('geyser')) return Icons.hot_tub_rounded;
    if (key.contains('tv')) return Icons.tv_rounded;
    return Icons.build_circle_outlined;
  }
}
