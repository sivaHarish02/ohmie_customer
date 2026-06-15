import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ohmie_customer/core/routes/app_routes.dart';
import 'package:ohmie_customer/feature/history/models/history_model.dart';
import 'package:ohmie_customer/feature/history/services/history_service.dart';

class HistoryController extends GetxController {
  HistoryController(this._service);

  final HistoryService _service;

  // ── State ──────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isPaginating = false.obs;
  final hasError = false.obs;
  final historyJobs = <HistoryJob>[].obs;
  final selectedStatus = ''.obs; // '' = All
  final currentPage = 1.obs;
  final totalJobs = 0.obs;
  final searchController = TextEditingController();

  // Summary counts derived from total loaded list
  int get completedCount =>
      historyJobs.where((j) => j.status == 'COMPLETED').length;
  int get cancelledCount =>
      historyJobs.where((j) => j.status == 'CANCELLED').length;

  bool get hasMore => historyJobs.length < totalJobs.value;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ── Methods ────────────────────────────────────────────────────────────────

  Future<void> loadHistory() async {
    if (isLoading.value) return;
    isLoading.value = true;
    hasError.value = false;
    currentPage.value = 1;
    try {
      final result = await _service.fetchHistory(
        page: 1,
        limit: 10,
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        search: searchController.text.trim().isEmpty
            ? null
            : searchController.text.trim(),
      );
      historyJobs.assignAll(result.jobs);
      totalJobs.value = result.total;
    } catch (_) {
      hasError.value = true;
      Get.snackbar(
        'Error',
        'Failed to load history. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHistory() async => loadHistory();

  Future<void> loadMore() async {
    if (isPaginating.value || !hasMore) return;
    isPaginating.value = true;
    try {
      final next = currentPage.value + 1;
      final result = await _service.fetchHistory(
        page: next,
        limit: 10,
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
        search: searchController.text.trim().isEmpty
            ? null
            : searchController.text.trim(),
      );
      historyJobs.addAll(result.jobs);
      currentPage.value = next;
      totalJobs.value = result.total;
    } catch (_) {
      // silent – user can scroll again
    } finally {
      isPaginating.value = false;
    }
  }

  void filterByStatus(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    loadHistory();
  }

  void searchHistory() => loadHistory();

  void rebookService(HistoryJob job) {
    Get.toNamed(
      AppRoutes.booking,
      arguments: {'categoryName': job.categoryName},
    );
  }
}
