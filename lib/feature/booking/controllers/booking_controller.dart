import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ohmie_customer/core/constants/app_colors.dart';
import 'package:ohmie_customer/core/routes/app_routes.dart';
import 'package:ohmie_customer/feature/booking/models/booking_model.dart';
import 'package:ohmie_customer/feature/booking/services/booking_service.dart';
import 'package:ohmie_customer/feature/location/controllers/location_controller.dart';
import 'package:ohmie_customer/feature/location/views/map_picker_screen.dart';

class BookingController extends GetxController {
  BookingController(this._service);

  final BookingService _service;

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final categories = <BookingCategory>[].obs;
  final selectedCategory = Rxn<BookingCategory>();
  final selectedProblemChip = ''.obs;
  final problemTitleController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedDate = Rx<DateTime>(DateTime.now());
  final selectedDatePreset = 'today'.obs;
  final selectedTimeSlot = ''.obs;
  final latitude = RxnDouble();
  final longitude = RxnDouble();
  final addressController = TextEditingController();
  final selectedImage = Rxn<XFile>();
  final currentStep = 1.obs;
  final categorySearchController = TextEditingController();

  late final LocationController _locationController;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> timeSlots = const [
    {'label': 'Morning 9 AM - 12 PM', 'hour': 9},
    {'label': 'Afternoon 12 PM - 3 PM', 'hour': 12},
    {'label': 'Evening 3 PM - 6 PM', 'hour': 15},
    {'label': 'Night 6 PM - 9 PM', 'hour': 18},
  ];

  final Map<String, List<String>> issueChipsByCategory = const {
    'ac service': [
      'Not cooling',
      'Water leakage',
      'Gas refill',
      'Noise issue',
      'General service',
    ],
    'washing machine': [
      'Not spinning',
      'Water not draining',
      'Noise issue',
      'Door issue',
      'General service',
    ],
    'refrigerator': [
      'Not cooling',
      'Ice buildup',
      'Water leakage',
      'Compressor issue',
      'General service',
    ],
    'ro service': [
      'No water output',
      'Filter replacement',
      'Leakage',
      'Bad taste',
      'General service',
    ],
    'electrical': [
      'Switch issue',
      'Power trip',
      'Wiring issue',
      'Fan issue',
      'General service',
    ],
    'plumbing': [
      'Pipe leakage',
      'Tap issue',
      'Drain blockage',
      'Toilet issue',
      'General service',
    ],
    'geyser': [
      'Not heating',
      'Water leakage',
      'Temperature issue',
      'Power issue',
      'General service',
    ],
    'tv repair': [
      'No display',
      'No sound',
      'Remote issue',
      'Screen lines',
      'General service',
    ],
  };

  List<BookingCategory> get filteredCategories {
    final q = categorySearchController.text.trim().toLowerCase();
    if (q.isEmpty) return categories;
    return categories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  List<String> get quickIssueChips {
    final name = selectedCategory.value?.name.toLowerCase() ?? '';
    return issueChipsByCategory[name] ??
        <String>['General service', 'Inspection', 'Repair needed'];
  }

  bool get hasLocation =>
      latitude.value != null &&
      longitude.value != null &&
      addressController.text.trim().isNotEmpty;

  bool get isLocating => _locationController.isLocating.value;

  DateTime? get preferredDateTime {
    if (selectedTimeSlot.value.isEmpty) return null;
    final slot = timeSlots.cast<Map<String, dynamic>?>().firstWhere(
          (e) => e?['label'] == selectedTimeSlot.value,
          orElse: () => null,
        );
    if (slot == null) return null;

    final hour = slot['hour'] as int;
    final d = selectedDate.value;
    return DateTime(d.year, d.month, d.day, hour, 0, 0);
  }

  @override
  void onInit() {
    super.onInit();
    _locationController = Get.find<LocationController>();

    categorySearchController.addListener(update);

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final id = int.tryParse((args['id'] ?? '').toString()) ?? 0;
      if (id > 0) {
        selectedCategory.value = BookingCategory(
          id: id,
          name: (args['name'] ?? '').toString(),
          icon: (args['icon'] ?? '').toString(),
        );
      }
    }

    _syncLocationFromController();
    loadCategories();
    _recomputeCurrentStep();
  }

  @override
  void onClose() {
    categorySearchController.dispose();
    problemTitleController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      final list = await _service.fetchCategories();
      categories.assignAll(list);

      final selected = selectedCategory.value;
      if (selected != null) {
        final match = list
            .cast<BookingCategory?>()
            .firstWhere((c) => c?.id == selected.id, orElse: () => null);
        selectedCategory.value = match ?? selected;
      }
    } finally {
      isLoading.value = false;
      update();
      _recomputeCurrentStep();
    }
  }

  void selectCategory(BookingCategory category) {
    selectedCategory.value = category;
    selectedProblemChip.value = '';
    _recomputeCurrentStep();
  }

  void selectProblemChip(String chip) {
    if (selectedProblemChip.value == chip) {
      selectedProblemChip.value = '';
      if (problemTitleController.text.trim() == chip) {
        problemTitleController.clear();
      }
      _recomputeCurrentStep();
      return;
    }

    selectedProblemChip.value = chip;
    problemTitleController.text = chip;
    problemTitleController.selection = TextSelection.fromPosition(
      TextPosition(offset: problemTitleController.text.length),
    );
    _recomputeCurrentStep();
  }

  void onIssueTextChanged() {
    if (selectedProblemChip.value.isNotEmpty &&
        problemTitleController.text.trim() != selectedProblemChip.value) {
      selectedProblemChip.value = '';
    }
    _recomputeCurrentStep();
  }

  Future<void> pickDatePreset(String preset) async {
    final now = DateTime.now();
    if (preset == 'today') {
      selectedDate.value = DateTime(now.year, now.month, now.day);
      selectedDatePreset.value = 'today';
    } else if (preset == 'tomorrow') {
      final t = now.add(const Duration(days: 1));
      selectedDate.value = DateTime(t.year, t.month, t.day);
      selectedDatePreset.value = 'tomorrow';
    } else {
      await pickDate();
      return;
    }
    _recomputeCurrentStep();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFED155D),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDate.value = picked;
      selectedDatePreset.value = 'custom';
      _recomputeCurrentStep();
    }
  }

  void selectTimeSlot(String slot) {
    selectedTimeSlot.value = selectedTimeSlot.value == slot ? '' : slot;
    _recomputeCurrentStep();
  }

  Future<void> getCurrentLocation() async {
    await _locationController.getCurrentLocation();
    _syncLocationFromController();
    _recomputeCurrentStep();
  }

  Future<void> openMapPicker() async {
    await Get.to(() => const MapPickerScreen());
    _syncLocationFromController();
    _recomputeCurrentStep();
  }

  void onAddressChanged() {
    _locationController.address.value = addressController.text.trim();
    _recomputeCurrentStep();
  }

  Future<void> pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1440,
    );
    if (file != null) {
      selectedImage.value = file;
      _recomputeCurrentStep();
    }
  }

  void removeImage() {
    selectedImage.value = null;
    _recomputeCurrentStep();
  }

  bool validateBooking() {
    if (selectedCategory.value == null) {
      Get.snackbar('Validation', 'Please select a service category.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (problemTitleController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Problem title is required.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (preferredDateTime == null) {
      Get.snackbar('Validation', 'Please select preferred date and time.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (!hasLocation) {
      Get.snackbar('Validation', 'Please confirm your location.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    return true;
  }

  Future<void> submitBooking() async {
    if (!validateBooking()) return;

    isSubmitting.value = true;
    try {
      final problemTitle = problemTitleController.text.trim();
      final description = descriptionController.text.trim();
      final request = BookingRequest(
        categoryId: selectedCategory.value!.id,
        problemTitle: problemTitle,
        description: description.isEmpty ? problemTitle : description,
        preferredTime: preferredDateTime!,
        latitude: latitude.value!,
        longitude: longitude.value!,
        address: addressController.text.trim(),
        image: selectedImage.value?.name,
      );

      final result = await _service.submitBooking(
        request,
        imageFile: selectedImage.value,
      );

      await _showBookingConfirmedDialog(result.message);

      if (result.jobId != null) {
        Get.offAllNamed(
          AppRoutes.tracking,
          arguments: {'jobId': result.jobId.toString()},
        );
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (_) {
      Get.snackbar(
        'Booking Failed',
        'Unable to confirm booking. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadCategories();
  }

  void _syncLocationFromController() {
    if (_locationController.latitude.value != null &&
        _locationController.longitude.value != null) {
      latitude.value = _locationController.latitude.value;
      longitude.value = _locationController.longitude.value;
      addressController.text = _locationController.address.value;
    }
  }

  void _recomputeCurrentStep() {
    final categoryDone = selectedCategory.value != null;
    final issueDone = problemTitleController.text.trim().isNotEmpty;
    final dateTimeDone = preferredDateTime != null;
    final locationDone = hasLocation;

    // Keep step progression sequential. A later section should not advance
    // progress unless all earlier sections are already complete.
    if (!categoryDone) {
      currentStep.value = 1;
      return;
    }
    if (!issueDone) {
      currentStep.value = 2;
      return;
    }
    if (!dateTimeDone) {
      currentStep.value = 3;
      return;
    }
    if (!locationDone) {
      currentStep.value = 4;
      return;
    }

    currentStep.value = 5;
  }

  Future<void> _showBookingConfirmedDialog(String message) {
    return Get.dialog<void>(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Booking Confirmed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('View Booking Status'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
