import 'package:balawi_app/core/network/api_response.dart';
import 'package:balawi_app/core/network/dio_service.dart';
import 'package:balawi_app/features/customers/data/models/customer_model.dart';
import 'package:dio/dio.dart';

/// Customer API Service
/// Handles all customer-related API operations
class CustomerService {
  final DioService _dioService = DioService.instance;
  static const String _customersEndpoint = '/customers';

  /// Get all customers with optional search, filter, and pagination
  ///
  /// [search] - Search by customer name (partial match, case-insensitive)
  /// [letter] - Filter by first letter of fullName
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 10)
  Future<ApiResponse<CustomersListData>> getAllCustomers({
    String? search,
    String? letter,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (letter != null && letter.isNotEmpty) {
        queryParams['letter'] = letter;
      }

      final response = await _dioService.get(
        _customersEndpoint,
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => CustomersListData.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<CustomersListData>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: DioService.handleError(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<CustomersListData>(
        success: false,
        statusCode: 0,
        message: 'حدث خطأ غير متوقع: $e',
        data: null,
      );
    }
  }

  /// Get customer by ID
  Future<ApiResponse<CustomerModel>> getCustomerById(String id) async {
    try {
      final response = await _dioService.get('$_customersEndpoint/$id');

      return ApiResponse.fromJson(
        response.data,
        (data) => CustomerModel.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<CustomerModel>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: DioService.handleError(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<CustomerModel>(
        success: false,
        statusCode: 0,
        message: 'حدث خطأ غير متوقع: $e',
        data: null,
      );
    }
  }

  /// Create a new customer
  Future<ApiResponse<CustomerModel>> createCustomer(
    CustomerModel customer,
  ) async {
    try {
      final response = await _dioService.post(
        _customersEndpoint,
        data: customer.toJson(),
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => CustomerModel.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<CustomerModel>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: DioService.handleError(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<CustomerModel>(
        success: false,
        statusCode: 0,
        message: 'حدث خطأ غير متوقع: $e',
        data: null,
      );
    }
  }

  /// Update an existing customer
  Future<ApiResponse<CustomerModel>> updateCustomer(
    String id,
    CustomerModel customer,
  ) async {
    try {
      final response = await _dioService.put(
        '$_customersEndpoint/$id',
        data: customer.toJsonForUpdate(),
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => CustomerModel.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<CustomerModel>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: DioService.handleError(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<CustomerModel>(
        success: false,
        statusCode: 0,
        message: 'حدث خطأ غير متوقع: $e',
        data: null,
      );
    }
  }

  /// Delete a customer
  Future<ApiResponse<CustomerModel>> deleteCustomer(String id) async {
    try {
      final response = await _dioService.delete('$_customersEndpoint/$id');

      return ApiResponse.fromJson(
        response.data,
        (data) => CustomerModel.fromJson(data),
      );
    } on DioException catch (e) {
      return ApiResponse<CustomerModel>(
        success: false,
        statusCode: e.response?.statusCode ?? 0,
        message: DioService.handleError(e),
        data: null,
      );
    } catch (e) {
      return ApiResponse<CustomerModel>(
        success: false,
        statusCode: 0,
        message: 'حدث خطأ غير متوقع: $e',
        data: null,
      );
    }
  }
}

/// Response data for customers list
class CustomersListData {
  final List<CustomerModel> customers;
  final PaginationModel pagination;

  CustomersListData({required this.customers, required this.pagination});

  factory CustomersListData.fromJson(Map<String, dynamic> json) {
    final customersList =
        (json['customers'] as List<dynamic>?)
            ?.map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return CustomersListData(
      customers: customersList,
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}
