import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ohmie_customer/core/constants/app_constants.dart';
import 'package:ohmie_customer/core/network/api_client.dart';
import 'package:ohmie_customer/core/services/socket_service.dart';
import 'package:ohmie_customer/feature/tracking/models/job_model.dart';

class TrackingController extends GetxController {
  // ── Reactive state ─────────────────────────────────────────────────────────
  late final RxString jobId;
  final Rxn<JobModel> job = Rxn<JobModel>();
  final RxBool isLoading = false.obs;

  // ── Dependencies ───────────────────────────────────────────────────────────
  late final ApiClient _apiClient;
  late final SocketService _socketService;

  // ── Socket event names used locally ───────────────────────────────────────
  static const String _evtJobUpdated = AppConstants.socketEventJobUpdated;
  static const String _evtJobCompleted = AppConstants.socketEventJobCompleted;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final id = (args is Map ? args['jobId'] : null)?.toString() ?? '';
    jobId = id.obs;

    _apiClient = Get.find<ApiClient>();
    _socketService = Get.find<SocketService>();

    loadJob();
    _listenSocket();
  }

  @override
  void onClose() {
    _socketService.off(_evtJobUpdated);
    _socketService.off(_evtJobCompleted);
    super.onClose();
  }

  // ── Data fetching ──────────────────────────────────────────────────────────
  Future<void> loadJob() async {
    if (jobId.value.isEmpty) return;
    isLoading.value = true;
    try {
      final response = await _apiClient.get('/customer/jobs/${jobId.value}');
      final body = response.data;
      Map<String, dynamic>? jobData;
      if (body is Map<String, dynamic> && body['data'] is Map) {
        jobData = body['data'] as Map<String, dynamic>;
      } else if (body is Map<String, dynamic>) {
        jobData = body;
      }
      if (jobData != null) {
        job.value = JobModel.fromJson(jobData);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ??
          e.message ??
          'Failed to load job details.';
      Get.snackbar(
        'Error',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _listenSocket() {
    _socketService.on(_evtJobUpdated, (data) {
      if (data == null) return;
      final map = _toMap(data);
      final incomingId = (map['job_id'] ?? map['id'] ?? map['_id'])?.toString();
      if (incomingId == null || incomingId == jobId.value) {
        loadJob();
      }
    });

    _socketService.on(_evtJobCompleted, (data) {
      if (data == null) return;
      final map = _toMap(data);
      final incomingId = (map['job_id'] ?? map['id'] ?? map['_id'])?.toString();
      if (incomingId == null || incomingId == jobId.value) {
        loadJob();
      }
    });
  }

  // ── Derived properties ─────────────────────────────────────────────────────

  /// List of ordered statuses for the happy-path stepper (index = step number)
  static const List<String> _orderedStatuses = [
    AppConstants.jobStatusCreated,
    AppConstants.jobStatusAssigned,
    AppConstants.jobStatusAccepted,
    AppConstants.jobStatusInProgress,
    AppConstants.jobStatusWaitingOtp,
    AppConstants.jobStatusCompleted,
  ];

  int get _statusIndex {
    final s = job.value?.status ?? AppConstants.jobStatusCreated;
    final idx = _orderedStatuses.indexOf(s);
    return idx < 0 ? 0 : idx;
  }

  /// Progress from 0.0 (PENDING) to 1.0 (COMPLETED)
  double get statusProgress {
    final maxIdx = _orderedStatuses.length - 1;
    return maxIdx == 0 ? 0.0 : _statusIndex / maxIdx;
  }

  Color get statusColor {
    switch (job.value?.status) {
      case AppConstants.jobStatusCreated:
        return Colors.grey;
      case AppConstants.jobStatusAssigned:
        return const Color(0xFF42A5F5); // blue
      case AppConstants.jobStatusAccepted:
        return AppConstants.primaryColor; // orange
      case AppConstants.jobStatusInProgress:
        return const Color(0xFF3949AB); // indigo
      case AppConstants.jobStatusWaitingApproval:
        return const Color(0xFFAB47BC); // purple
      case AppConstants.jobStatusWaitingOtp:
        return const Color(0xFFBF360C); // deep orange
      case AppConstants.jobStatusCompleted:
        return AppConstants.successColor;
      case AppConstants.jobStatusClosed:
        return const Color(0xFF00695C); // teal
      case AppConstants.jobStatusRejected:
        return AppConstants.errorColor;
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  String get statusLabel {
    switch (job.value?.status) {
      case AppConstants.jobStatusCreated:
        return 'Booking Submitted';
      case AppConstants.jobStatusAssigned:
        return 'Technician Assigned';
      case AppConstants.jobStatusAccepted:
        return 'On the Way';
      case AppConstants.jobStatusInProgress:
        return 'Work in Progress';
      case AppConstants.jobStatusWaitingApproval:
        return 'Awaiting Approval';
      case AppConstants.jobStatusWaitingOtp:
        return 'Share OTP';
      case AppConstants.jobStatusCompleted:
        return 'Completed';
      case AppConstants.jobStatusClosed:
        return 'Closed';
      case AppConstants.jobStatusRejected:
        return 'Rejected';
      default:
        return job.value?.status ?? 'Unknown';
    }
  }

  String statusStepLabel(String status) {
    switch (status) {
      case AppConstants.jobStatusCreated:
        return 'Created';
      case AppConstants.jobStatusAssigned:
        return 'Assigned';
      case AppConstants.jobStatusAccepted:
        return 'On Way';
      case AppConstants.jobStatusInProgress:
        return 'In Progress';
      case AppConstants.jobStatusWaitingOtp:
        return 'OTP';
      case AppConstants.jobStatusCompleted:
        return 'Done';
      default:
        return status;
    }
  }

  bool isStatusReached(String status) {
    final targetIdx = _orderedStatuses.indexOf(status);
    return targetIdx <= _statusIndex;
  }

  bool isStatusCurrent(String status) => job.value?.status == status;

  bool get showTechnicianCard {
    final s = job.value?.status;
    return s == AppConstants.jobStatusAssigned ||
        s == AppConstants.jobStatusAccepted ||
        s == AppConstants.jobStatusInProgress ||
        s == AppConstants.jobStatusWaitingApproval ||
        s == AppConstants.jobStatusWaitingOtp ||
        s == AppConstants.jobStatusCompleted;
  }

  bool get showOtpSection =>
      job.value?.status == AppConstants.jobStatusWaitingOtp;

  bool get showPaymentButton =>
      job.value?.status == AppConstants.jobStatusCompleted &&
      job.value?.paymentStatus != 'PAID';

  // ── Actions ────────────────────────────────────────────────────────────────
  void callTechnician() {
    final phone = job.value?.technicianPhone;
    if (phone == null || phone.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'Technician phone number is not available.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    // Strip mask and launch dialer — in production use url_launcher
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    // url_launcher is imported at screen level; emit event for screen to handle
    _callPhoneEvent.value = cleanPhone;
  }

  /// Exposed so the UI layer can listen and launch url_launcher
  final RxString _callPhoneEvent = ''.obs;
  RxString get callPhoneEvent => _callPhoneEvent;

  // ── Private helpers ────────────────────────────────────────────────────────
  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    try {
      return Map<String, dynamic>.from(data as Map);
    } catch (_) {
      return {};
    }
  }
}
