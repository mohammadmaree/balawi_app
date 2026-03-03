import 'package:balawi_app/core/network/api_response.dart';
import 'package:balawi_app/core/network/dio_service.dart';
import 'package:balawi_app/features/deliveries/data/models/statistics_model.dart';
import 'package:balawi_app/features/deliveries/data/models/work_order_model.dart';
import 'package:dio/dio.dart';

/// Work Order API Service
class WorkOrderService {
  final DioService _dioService = DioService.instance;
  static const String _workOrdersEndpoint = '/work-orders';

  /// Get all work orders with optional filters
  Future<ApiResponse<WorkOrdersListData>> getAllWorkOrders({
    String? search,
    String? status,
    String? shelfNumber,
    bool? isPaid,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (shelfNumber != null && shelfNumber.isNotEmpty) {
        queryParams['shelfNumber'] = shelfNumber;
      }
      if (isPaid != null) {
        queryParams['isPaid'] = isPaid;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams['dateFrom'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams['dateTo'] = dateTo;
      }

      final response = await _dioService.get(
        _workOrdersEndpoint,
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => WorkOrdersListData.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<WorkOrdersListData>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: DioService.handleError(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<WorkOrdersListData>(
        success: false,
        statusCode: 0,
        message: 'حدث خطأ غير متوقع: $e',
        data: null,
      );
    }
  }

  /// Get statistics
  Future<ApiResponse<StatisticsModel>> getStatistics() async {
    try {
      final response = await _dioService.get('$_workOrdersEndpoint/statistics');

      return ApiResponse.fromJson(
        response.data,
        (data) => StatisticsModel.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<StatisticsModel>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: DioService.handleError(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<StatisticsModel>(
        success: false,
        statusCode: 0,
        message: 'حدث خطأ غير متوقع: $e',
        data: null,
      );
    }
  }

  /// Get work order by ID
  Future<ApiResponse<WorkOrderModel>> getWorkOrderById(String id) async {
    try {
      final response = await _dioService.get('$_workOrdersEndpoint/$id');

      return ApiResponse.fromJson(
        response.data,
        (data) => WorkOrderModel.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<WorkOrderModel>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: DioService.handleError(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<WorkOrderModel>(
        success: false,
        statusCode: 0,
        message: 'حدث خطأ غير متوقع: $e',
        data: null,
      );
    }
  }

  /// Create a new work order
  Future<ApiResponse<WorkOrderModel>> createWorkOrder(
    WorkOrderModel workOrder,
  ) async {
    try {
      final response = await _dioService.post(
        _workOrdersEndpoint,
        data: workOrder.toJson(),
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => WorkOrderModel.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<WorkOrderModel>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: DioService.handleError(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<WorkOrderModel>(
        success: false,
        statusCode: 0,
        message: 'حدث خطأ غير متوقع: $e',
        data: null,
      );
    }
  }

  /// Update an existing work order
  Future<ApiResponse<WorkOrderModel>> updateWorkOrder(
    String id,
    WorkOrderModel workOrder,
  ) async {
    try {
      final response = await _dioService.put(
        '$_workOrdersEndpoint/$id',
        data: workOrder.toJsonForUpdate(),
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => WorkOrderModel.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<WorkOrderModel>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: DioService.handleError(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<WorkOrderModel>(
        success: false,
        statusCode: 0,
        message: 'حدث خطأ غير متوقع: $e',
        data: null,
      );
    }
  }

  /// Delete a work order
  Future<ApiResponse<WorkOrderModel>> deleteWorkOrder(String id) async {
    try {
      final response = await _dioService.delete('$_workOrdersEndpoint/$id');

      return ApiResponse.fromJson(
        response.data,
        (data) => WorkOrderModel.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<WorkOrderModel>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: DioService.handleError(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<WorkOrderModel>(
        success: false,
        statusCode: 0,
        message: 'حدث خطأ غير متوقع: $e',
        data: null,
      );
    }
  }
}

/// Response data for work orders list
class WorkOrdersListData {
  final List<WorkOrderModel> workOrders;
  final PaginationModel? pagination;

  WorkOrdersListData({required this.workOrders, this.pagination});

  factory WorkOrdersListData.fromJson(Map<String, dynamic> json) {
    final workOrdersList =
        (json['workOrders'] as List<dynamic>?)
            ?.map((e) => WorkOrderModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return WorkOrdersListData(
      workOrders: workOrdersList,
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}
