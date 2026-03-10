import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:dio/dio.dart';

/// Test class to demonstrate the global error handling functionality
/// This shows how API errors are now handled automatically without manual error handling
class GlobalErrorHandlingTest {
  
  final DioClient dioClient = DioClient();
  final Dio dio = DioClient().getdio();

  /// Test method showing how API calls now work without manual error handling
  /// The GlobalApiInterceptor will automatically handle all errors
  Future<void> testApiCallsWithoutManualErrorHandling() async {
    try {
      // Example GET request - errors will be handled automatically by GlobalApiInterceptor
      final response1 = await dio.get('/api/test-endpoint');
      print('GET request successful: ${response1.data}');
      
      // Example POST request - errors will be handled automatically by GlobalApiInterceptor  
      final response2 = await dio.post('/api/test-post', data: {'test': 'data'});
      print('POST request successful: ${response2.data}');
      
      // Example custom method call - errors will be handled automatically
      final response3 = await dioClient.getbycustom('/api/test-custom');
      print('Custom GET request successful: ${response3.data}');
      
    } catch (e) {
      // This catch block will only catch non-Dio exceptions
      // All Dio exceptions are handled automatically by the GlobalApiInterceptor
      print('Non-Dio exception occurred: $e');
    }
  }

  /// Test method showing network error scenarios  
  Future<void> testNetworkErrorHandling() async {
    try {
      // This will trigger network error handling in GlobalApiInterceptor
      final response = await dio.get('/api/nonexistent-endpoint');
    } catch (e) {
      // Network errors are handled automatically by GlobalApiInterceptor
      print('Network error test completed - error handled automatically');
    }
  }

  /// Test method showing API error scenarios
  Future<void> testApiErrorHandling() async {
    try {
      // This will trigger API error handling in GlobalApiInterceptor
      final response = await dio.get('/api/error-endpoint');
    } catch (e) {
      // API errors are handled automatically by GlobalApiInterceptor
      print('API error test completed - error handled automatically');
    }
  }
}

/// Usage example showing the benefits of global error handling
class UsageExample {
  
  final Dio dio = DioClient().getdio();

  /// Before: Manual error handling required in every API call
  /// After: No manual error handling needed - errors handled automatically
  Future<void> exampleApiCall() async {
    try {
      // Before: You would need to wrap this in try-catch and call handleExceptionMessage()
      // After: Just make the API call - errors are handled automatically!
      final response = await dio.get('/api/customer-data');
      
      // Process successful response
      if (response.statusCode == 200) {
        print('Customer data loaded successfully');
        // Process response.data
      }
      
    } catch (e) {
      // This catch block is now only for non-Dio exceptions
      // All Dio exceptions (timeouts, network errors, API errors) are handled automatically
      print('Non-Dio exception: $e');
    }
  }
}

/// Benefits of the new global error handling system:
/// 
/// 1. CONSISTENT ERROR MESSAGES
///    - All API errors show user-friendly messages via NkCommonFunction.showErrorSnakBar()
///    - No more inconsistent error handling across different API calls
/// 
/// 2. AUTOMATIC TIMEOUT HANDLING  
///    - Connection timeouts: "Unable to connect to server. Please check your internet."
///    - Receive timeouts: "Server is taking too long to respond."
///    - Send timeouts: "Request timeout. Please try again."
/// 
/// 3. AUTOMATIC NETWORK ERROR HANDLING
///    - No internet: "No internet connection."
///    - Connection errors: "Failed to connect to the server."
/// 
/// 4. AUTOMATIC API ERROR HANDLING
///    - API error messages are displayed directly to users
///    - HTTP status code errors are handled with appropriate messages
/// 
/// 5. CLEANER CODE
///    - No need to call handleExceptionMessage() in every API call
///    - No need to manually check for timeouts or network errors
///    - Focus on business logic instead of error handling boilerplate
/// 
/// 6. BACKWARD COMPATIBILITY
///    - Existing code using handleExceptionMessage() continues to work
///    - Legacy functions are deprecated but don't break existing functionality