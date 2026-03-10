import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class DioClient with ApiConstants {
  DioClient()
      : _dio = Dio(
          BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 20),
              responseType: ResponseType.json),
        )..interceptors.addAll([
            GlobalApiInterceptor(),
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
      final errorMessage = DioExceptionHandler.fromDioError(err).toString();
      return Future.error(errorMessage);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getbycustom<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    int maxRetries = 3,
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
        if (retryCount >= maxRetries ||
            err.type != DioExceptionType.connectionTimeout) {
          final errorMessage = DioExceptionHandler.fromDioError(err).toString();
          throw errorMessage;
        }
      } catch (e) {
        throw e.toString();
      }
    }

    throw 'Failed to complete the request after $maxRetries retries.';
  }

  Future<Response> patchbycustom<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (err) {
      final errorMessage = DioExceptionHandler.fromDioError(err).toString();
      return Future.error(errorMessage);
    } catch (e) {
      return Future.error(e);
    }
  }
}

Future<Response<dynamic>> responsePostMethod(
    {required Map<String, dynamic> requestData,
    String? endPoint,
    Options? options}) async {
  final response = await Dio()
      .post("${ApiConstants.baseUrl}$endPoint",
          data: requestData, options: options)
      .timeout(
    const Duration(seconds: 15),
    onTimeout: () {
      throw DioException(
        requestOptions:
            RequestOptions(path: "${ApiConstants.baseUrl}$endPoint"),
        type: DioExceptionType.connectionTimeout,
      );
    },
  );
  return response;
}

Future<Response<dynamic>> responseGetMethod(
    {Map<String, dynamic>? requestData,
    String? endPoint,
    Options? options,
    Map<String, dynamic>? queryParameters}) async {
  final response = await Dio()
      .post("${ApiConstants.baseUrl}$endPoint",
          data: requestData, options: options, queryParameters: queryParameters)
      .timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      throw DioException(
        requestOptions:
            RequestOptions(path: "${ApiConstants.baseUrl}$endPoint"),
        type: DioExceptionType.connectionTimeout,
      );
    },
  );
  return response;
}

class DioExceptionHandler implements Exception {
  late String errorMessage;

  DioExceptionHandler.fromDioError(DioException dioError,
      {bool showErrorSnakBar = true}) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        errorMessage =
            dioError.response?.data['message'] ?? 'Request was cancelled.';
        break;

      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timed out.';
        break;

      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout occurred.';
        break;

      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout occurred.';
        break;

      case DioExceptionType.badResponse:
        errorMessage = dioError.response?.data['message'] ??
            'Received invalid status code: ${dioError.response?.statusCode}.';
        break;

      case DioExceptionType.connectionError:
        errorMessage = 'Failed to connect to the server.';
        break;

      case DioExceptionType.badCertificate:
        errorMessage = 'Bad SSL Certificate.';
        break;

      default:
        errorMessage = 'An unexpected error occurred.';
        break;
    }
  }

  @override
  String toString() => errorMessage;
}

void handleHttpResponseError({
  required int statusCode,
  required Function(String message) showErrorSnackBar,
  String? message,
}) async {
  final isConnected = await ConnectivityService().isOnline();
  switch (statusCode) {
    case 400:
      showErrorSnackBar('Bad Request $message');
      break;
    case 401:
      showErrorSnackBar('Authentication failed.$message');
      break;
    case 403:
      showErrorSnackBar(
          'The authenticated user is not allowed to access the specified API endpoint.$message');
      break;
    case 404:
      showErrorSnackBar('The requested resource does not exist.$message');
      break;
    case 405:
      showErrorSnackBar(
          'Method not allowed. Please check the Allow header for the allowed HTTP methods.$message');
    case 415:
      showErrorSnackBar(
          'Unsupported media type. The requested content type or version number is invalid.$message');
      break;
    case 422:
      showErrorSnackBar('Data validation failed.$message');
      break;
    case 429:
      showErrorSnackBar('Too many requests.$message');
      break;
    case > 500:
      showErrorSnackBar('Internal server error.$message');
      break;
    default:
      isConnected
          ? showErrorSnackBar('Oops, something went wrong!$message')
          : '';
  }
}

/// Legacy function for backward compatibility
/// This function is now deprecated as errors are handled automatically by GlobalApiInterceptor
void handleExceptionMessage({
  Response<dynamic>? response,
  String? apiName,
  DioException? error,
}) {
  // This function is now deprecated as errors are handled automatically by GlobalApiInterceptor
  // The global interceptor will handle all errors automatically
  // This function is kept for backward compatibility but does nothing
}

/// Legacy function for backward compatibility
/// This function is now deprecated as errors are handled automatically by GlobalApiInterceptor
void errorSnackbar(String message) {
  // This function is now deprecated as errors are handled automatically by GlobalApiInterceptor
  // The global interceptor will handle all errors automatically
  // This function is kept for backward compatibility but does nothing
}


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
    return;
  }
}

/// Global API Interceptor that handles all API errors automatically
/// This eliminates the need to call handleExceptionMessage() in every API call
class GlobalApiInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = "";

    /// API response error message
    final responseData = err.response?.data;

    if (responseData is Map<String, dynamic> &&
        responseData['message'] != null) {
      message = responseData['message'].toString();
    }

    /// Timeout handling
    if (err.type == DioExceptionType.connectionTimeout) {
      NkCommonFunction.showErrorSnakBar(
          "Unable to connect to server. Please check your internet.");
    } else if (err.type == DioExceptionType.receiveTimeout) {
      NkCommonFunction.showErrorSnakBar(
          "Server is taking too long to respond.");
    } else if (err.type == DioExceptionType.sendTimeout) {
      NkCommonFunction.showErrorSnakBar("Request timeout. Please try again.");
    } else if (err.type == DioExceptionType.connectionError) {
      NkCommonFunction.showErrorSnakBar("No internet connection.");
    }

    /// API returned error
    else if (message.isNotEmpty) {
      NkCommonFunction.showErrorSnakBar(message);
    }

    /// HTTP status errors
    else {
      int statusCode = err.response?.statusCode ?? 0;
      handleHttpResponseError(
        statusCode: statusCode,
        showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
        message: "",
      );
    }

    super.onError(err, handler);
  }
}
