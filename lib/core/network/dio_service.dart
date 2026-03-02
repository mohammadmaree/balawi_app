import 'dart:io';
import 'package:dio/dio.dart';

/// Dio HTTP client service
class DioService {
  static DioService? _instance;
  late Dio _dio;

  // For Android emulator use 10.0.2.2, for iOS simulator use localhost
  // For physical device, use your computer's local IP (e.g., 192.168.x.x)
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.1.19:3000/api'; // Android emulator
    } else {
      return 'http://192.168.1.19:3000/api'; // iOS simulator
    }
  }

  DioService._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
          print('📦 Data: ${options.data}');
          print('🔍 Query: ${options.queryParameters}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          print('📦 Data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print(
            '❌ ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
          );
          print('📦 Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  /// Get the singleton instance
  static DioService get instance {
    _instance ??= DioService._();
    return _instance!;
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Handle Dio errors and return user-friendly messages
  static String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة إرسال البيانات. يرجى المحاولة مرة أخرى.';
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة استقبال البيانات. يرجى المحاولة مرة أخرى.';
      case DioExceptionType.badCertificate:
        return 'شهادة أمان غير صالحة.';
      case DioExceptionType.badResponse:
        // Try to extract message from response data first
        final responseData = error.response?.data;
        if (responseData != null && responseData is Map<String, dynamic>) {
          final message = responseData['message'];
          if (message != null && message is String && message.isNotEmpty) {
            return message;
          }
        }
        return _handleStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب.';
      case DioExceptionType.connectionError:
        return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.';
      case DioExceptionType.unknown:
        return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
    }
  }

  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'طلب غير صالح.';
      case 401:
        return 'غير مصرح. يرجى تسجيل الدخول.';
      case 403:
        return 'ممنوع الوصول.';
      case 404:
        return 'المورد غير موجود.';
      case 409:
        return 'يوجد تعارض في البيانات.';
      case 500:
        return 'خطأ في الخادم. يرجى المحاولة لاحقاً.';
      default:
        return 'حدث خطأ. يرجى المحاولة مرة أخرى.';
    }
  }
}
