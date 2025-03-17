import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class DioClient with ApiConstants {
  DioClient()
      : _dio = Dio(
          BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
              responseType: ResponseType.json),
        )..interceptors.addAll([
            AuthorizationInterceptor(),
            LoggerInterceptor(),
          ]);

  late final Dio _dio;

  Dio getdio() {
    return _dio;
  }

  Future<Response> postbycustom<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool showErrorSnakBar = true,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      return response;
    } on DioException catch (err) {
      log('Post Requested Path: $path');
      log('DioError: ${err.response?.data}');
      return err.response ?? Future.error("No response from server");
    } catch (e) {
      log('General Error: $e');
      return Future.error(e);
    }
  }

Future<Response> getbycustom<T>(
  String path, {
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  ProgressCallback? onReceiveProgress,
  int maxRetries = 3, // Retry count
}) async {
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (err) {
      retryCount++;
      if (retryCount >= maxRetries || err.type != DioExceptionType.connectionTimeout) {
        final errorMessage = DioExceptionHandler.fromDioError(err).toString();
        throw errorMessage;
      }
      log('Retrying request ($retryCount/$maxRetries): $path');
    } catch (e) {
      throw e.toString();
    }
  }

  throw 'Failed to complete the request after $maxRetries retries.';
}

}

class DioExceptionHandler implements Exception {
  late String errorMessage;
  late String type;

  DioExceptionHandler.fromDioError(DioException dioError,
      {bool showErrorSnakBar = true}) {

    switch (dioError.type) {
      case DioExceptionType.cancel:
        errorMessage =
            dioError.response?.data['message'] ?? 'Request was cancelled.';
        if (showErrorSnakBar) NkCommonFunction.showErrorSnakBar(errorMessage);
        break;

      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timed out.';
        if (showErrorSnakBar) NkCommonFunction.showErrorSnakBar(errorMessage);
        break;

      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout occurred.';
        if (showErrorSnakBar) NkCommonFunction.showErrorSnakBar(errorMessage);
        break;

      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout occurred.';
        if (showErrorSnakBar) NkCommonFunction.showErrorSnakBar(errorMessage);
        break;

      case DioExceptionType.badResponse:
        // Handles HTTP status errors
        errorMessage = dioError.response?.data['message'] ??
            'Received invalid status code: ${dioError.response?.statusCode}.';
        if (showErrorSnakBar) NkCommonFunction.showErrorSnakBar(errorMessage);
        break;

      case DioExceptionType.connectionError:
        errorMessage = 'Failed to connect to the server.';
        if (showErrorSnakBar) NkCommonFunction.showErrorSnakBar(errorMessage);
        break;

      case DioExceptionType.badCertificate:
        errorMessage = 'Bad SSL Certificate.';
        if (showErrorSnakBar) NkCommonFunction.showErrorSnakBar(errorMessage);
        break;

      default:
        errorMessage = 'An unexpected error occurred.';
        if (showErrorSnakBar) NkCommonFunction.showErrorSnakBar(errorMessage);
        break;
    }
  }
  @override
  String toString() => errorMessage;
}

/*
  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Authentication failed.';
      case 403:
        return 'The authenticated user is not allowed to access the specified API endpoint.';
      case 404:
        return 'The requested resource does not exist.';
      case 405:
        return 'Method not allowed. Please check the Allow header for the allowed HTTP methods.';
      case 415:
        return 'Unsupported media type. The requested content type or version number is invalid.';
      case 422:
        return 'Data validation failed.';
      case 429:
        return 'Too many requests.';
      case 500:
        return 'Internal server error.';
      default:
        return 'Oops something went wrong!';
    }
  }
*/

class AuthorizationInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_needAuthorizationHeader(options)) {
      // adds the access-token with the header
      // options.headers['Authorization'] = 'Bearer $API_KEY';
    }
    // continue with the request
    super.onRequest(options, handler);
  }

  bool _needAuthorizationHeader(RequestOptions options) {
    if (options.method == 'GET') {
      return false;
    } else {
      return true;
    }
  }
}

class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(
    // Customize the printer
    printer: PrettyPrinter(
      methodCount: 0,
      colors: true,
      printEmojis: true,
      // ignore: deprecated_member_use
      printTime: false,
    ),
  );

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    logger.e('${options.method} request => $requestPath'); // Debug log
    logger.d('Error: ${err.error}, Message: ${err.message}'); // Error log
    // Error log
    return;
    //super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('${options.method} request => $requestPath');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d(
        'StatusCode: ${response.statusCode}, Data: ${response.data}'); // Debug log
    return super.onResponse(response, handler);
  }
}
