import 'package:balawi_app/core/network/api_response.dart';
import 'package:balawi_app/features/deliveries/data/models/statistics_model.dart';
import 'package:balawi_app/features/deliveries/data/models/work_order_model.dart';
import 'package:balawi_app/features/deliveries/data/services/work_order_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveriesController extends GetxController {
  final WorkOrderService _workOrderService = WorkOrderService();

  TextEditingController searchTextController = TextEditingController();

  // Loading states
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isSubmitting = false;
  bool isLoadingStats = false;
  String? errorMessage;

  // Work order data
  List<WorkOrderModel> workOrders = [];
  PaginationModel? pagination;
  StatisticsModel? statistics;

  // Filter state
  String? selectedStatus;
  String? selectedShelf;
  bool? selectedPaymentStatus;
  String? searchQuery;
  DateTime? selectedDateFrom;
  DateTime? selectedDateTo;

  @override
  void onInit() {
    super.onInit();
    fetchWorkOrders();
    fetchStatistics();
  }

  /// Fetch work orders from API
  Future<void> fetchWorkOrders({
    bool refresh = false,
    bool loadMore = false,
  }) async {
    if (isLoading || isLoadingMore) return;

    if (loadMore && pagination != null) {
      if (pagination!.currentPage >= pagination!.totalPages) return;
      isLoadingMore = true;
    } else {
      isLoading = true;
      if (refresh) {
        workOrders = [];
        pagination = null;
      }
    }
    errorMessage = null;
    update();

    final int page = loadMore && pagination != null
        ? pagination!.currentPage + 1
        : 1;

    final response = await _workOrderService.getAllWorkOrders(
      search: searchQuery,
      status: selectedStatus,
      shelfNumber: selectedShelf,
      isPaid: selectedPaymentStatus,
      dateFrom: selectedDateFrom?.toIso8601String(),
      dateTo: selectedDateTo?.toIso8601String(),
      page: page,
      limit: 10,
    );

    if (response.success && response.data != null) {
      if (loadMore) {
        workOrders.addAll(response.data!.workOrders);
      } else {
        workOrders = response.data!.workOrders;
      }
      pagination = response.data!.pagination;
    } else {
      errorMessage = response.message;
    }

    isLoading = false;
    isLoadingMore = false;
    update();
  }

  /// Fetch statistics
  Future<void> fetchStatistics() async {
    isLoadingStats = true;
    update();

    final response = await _workOrderService.getStatistics();

    if (response.success && response.data != null) {
      statistics = response.data;
    }

    isLoadingStats = false;
    update();
  }

  /// Search work orders
  Future<void> search() async {
    searchQuery = searchTextController.text.trim();
    await fetchWorkOrders(refresh: true);
  }

  /// Clear search
  Future<void> clearSearch() async {
    searchTextController.clear();
    searchQuery = null;
    await fetchWorkOrders(refresh: true);
  }

  /// Apply filters
  Future<void> applyFilters({
    String? status,
    String? shelf,
    bool? paymentStatus,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    selectedStatus = status;
    selectedShelf = shelf;
    selectedPaymentStatus = paymentStatus;
    selectedDateFrom = dateFrom;
    selectedDateTo = dateTo;
    await fetchWorkOrders(refresh: true);
  }

  /// Clear filters
  Future<void> clearFilters() async {
    selectedStatus = null;
    selectedShelf = null;
    selectedPaymentStatus = null;
    selectedDateFrom = null;
    selectedDateTo = null;
    await fetchWorkOrders(refresh: true);
  }

  /// Check if any filter is active
  bool get hasActiveFilters {
    return selectedStatus != null ||
        selectedShelf != null ||
        selectedPaymentStatus != null ||
        selectedDateFrom != null ||
        selectedDateTo != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }

  /// Create a new work order
  Future<bool> createWorkOrder(WorkOrderModel workOrder) async {
    isSubmitting = true;
    errorMessage = null;
    update();

    final response = await _workOrderService.createWorkOrder(workOrder);

    isSubmitting = false;
    if (response.success && response.data != null) {
      workOrders.insert(0, response.data!);
      await fetchStatistics(); // Refresh statistics
      update();
      return true;
    } else {
      errorMessage = response.message;
      update();
      return false;
    }
  }

  /// Update an existing work order
  Future<bool> updateWorkOrder(String id, WorkOrderModel workOrder) async {
    isSubmitting = true;
    errorMessage = null;
    update();

    final response = await _workOrderService.updateWorkOrder(id, workOrder);

    isSubmitting = false;
    if (response.success && response.data != null) {
      final index = workOrders.indexWhere((w) => w.id == id);
      if (index != -1) {
        workOrders[index] = response.data!;
      }
      await fetchStatistics(); // Refresh statistics
      update();
      return true;
    } else {
      errorMessage = response.message;
      update();
      return false;
    }
  }

  /// Delete a work order
  Future<bool> deleteWorkOrder(String id) async {
    isSubmitting = true;
    errorMessage = null;

    final orderIndex = workOrders.indexWhere((w) => w.id == id);
    WorkOrderModel? removedOrder;
    if (orderIndex != -1) {
      removedOrder = workOrders[orderIndex];
      workOrders.removeAt(orderIndex);
    }
    update();

    final response = await _workOrderService.deleteWorkOrder(id);

    isSubmitting = false;
    if (response.success) {
      await fetchStatistics(); // Refresh statistics
      update();
      return true;
    } else {
      if (removedOrder != null && orderIndex != -1) {
        workOrders.insert(orderIndex, removedOrder);
      }
      errorMessage = response.message;
      update();
      return false;
    }
  }

  /// Mark as delivered
  Future<bool> markAsDelivered(String id, {bool isPaid = false}) async {
    final workOrder = WorkOrderModel(status: 'تم التسليم', isPaid: isPaid);
    return await updateWorkOrder(id, workOrder);
  }
}
