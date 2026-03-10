# Global API Error Handling Implementation

This document explains the new global API error handling system implemented using Dio Interceptors for the ThriveWoo sales app.

## Overview

The global error handling system automatically handles all API errors without requiring manual error handling in every API call. This provides a consistent user experience and cleaner codebase.

## Key Components

### 1. GlobalApiInterceptor
Located in `lib/api_handler/dio_client.dart`

This interceptor automatically handles all Dio exceptions and displays appropriate error messages to users via `NkCommonFunction.showErrorSnakBar()`.

**Error Types Handled:**
- **Connection Timeout**: "Unable to connect to server. Please check your internet."
- **Receive Timeout**: "Server is taking too long to respond."
- **Send Timeout**: "Request timeout. Please try again."
- **Connection Error**: "No internet connection."
- **API Errors**: Displays the actual error message from the API response
- **HTTP Status Errors**: Handles 400, 401, 403, 404, 405, 415, 422, 429, and 500+ status codes

### 2. Updated DioClient
The `DioClient` class now includes the `GlobalApiInterceptor` in its interceptor chain:

```dart
DioClient()
    : _dio = Dio(
        BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 20),
            responseType: ResponseType.json),
      )..interceptors.addAll([
          GlobalApiInterceptor(),  // ← Added global error handling
          AuthorizationInterceptor(),
          LoggerInterceptor(),
        ]);
```

## Usage Examples

### Before: Manual Error Handling Required
```dart
Future<void> fetchCustomerData() async {
  try {
    final response = await dio.get('/api/customer-data');
    // Process response
  } catch (e) {
    // Manual error handling required
    handleExceptionMessage(response: e.response, apiName: 'Customer Data');
  }
}
```

### After: No Manual Error Handling Needed
```dart
Future<void> fetchCustomerData() async {
  try {
    final response = await dio.get('/api/customer-data');
    // Process response - errors handled automatically!
  } catch (e) {
    // This catch block is only for non-Dio exceptions
    // All Dio exceptions are handled automatically by GlobalApiInterceptor
    print('Non-Dio exception: $e');
  }
}
```

## Benefits

### 1. Consistent Error Messages
All API errors now show user-friendly messages through the snackbar system, ensuring a consistent user experience.

### 2. Automatic Timeout Handling
No need to manually check for timeout scenarios - they're handled automatically with appropriate user messages.

### 3. Automatic Network Error Handling
Network connectivity issues are detected and handled automatically with clear user messages.

### 4. Cleaner Code
API calls are now much cleaner without the need for manual error handling boilerplate.

### 5. Backward Compatibility
Existing code using `handleExceptionMessage()` continues to work. The function is deprecated but doesn't break existing functionality.

## Error Message Examples

### Timeout Errors
- **Connection Timeout**: "Unable to connect to server. Please check your internet."
- **Receive Timeout**: "Server is taking too long to respond."
- **Send Timeout**: "Request timeout. Please try again."

### Network Errors
- **No Internet**: "No internet connection."
- **Connection Error**: "Failed to connect to the server."

### API Errors
- **400 Bad Request**: "Bad Request [message]"
- **401 Unauthorized**: "Authentication failed. [message]"
- **403 Forbidden**: "The authenticated user is not allowed to access the specified API endpoint. [message]"
- **404 Not Found**: "The requested resource does not exist. [message]"
- **500+ Server Error**: "Internal server error. [message]"

## Migration Guide

### For New Code
Simply make API calls without manual error handling:

```dart
// New approach - errors handled automatically
Future<void> fetchData() async {
  try {
    final response = await dio.get('/api/data');
    // Process response
  } catch (e) {
    // Only catches non-Dio exceptions
  }
}
```

### For Existing Code
Existing code continues to work without changes. You can gradually remove `handleExceptionMessage()` calls:

```dart
// Old approach - still works but deprecated
Future<void> fetchData() async {
  try {
    final response = await dio.get('/api/data');
    // Process response
  } catch (e) {
    // This function is now deprecated but still works
    handleExceptionMessage(response: e.response, apiName: 'Data');
  }
}
```

## Testing

The `GlobalErrorHandlingTest` class in `lib/api_handler/global_error_handling_test.dart` demonstrates how the system works:

```dart
final test = GlobalErrorHandlingTest();

// Test API calls without manual error handling
await test.testApiCallsWithoutManualErrorHandling();

// Test timeout scenarios
await test.testTimeoutHandling();

// Test network error scenarios
await test.testNetworkErrorHandling();

// Test API error scenarios
await test.testApiErrorHandling();
```

## Implementation Details

### Error Flow
1. API call is made using Dio
2. If a DioException occurs, `GlobalApiInterceptor.onError()` is triggered
3. The interceptor determines the error type and displays appropriate message
4. The error is passed to the next handler (which may be the user's catch block)

### Message Display
All error messages are displayed using `NkCommonFunction.showErrorSnakBar()`, ensuring consistency with the existing app design.

### Status Code Handling
HTTP status codes are handled by the existing `handleHttpResponseError()` function, which provides specific messages for different error scenarios.

## Files Modified

1. **`lib/api_handler/dio_client.dart`**
   - Added `GlobalApiInterceptor` class
   - Updated `DioClient` constructor to include global interceptor
   - Deprecated `handleExceptionMessage()` and `errorSnackbar()` functions

2. **`lib/api_handler/global_error_handling_test.dart`** (New)
   - Test class demonstrating the functionality
   - Usage examples showing before/after approaches

## Future Improvements

1. **Custom Error Messages**: Could add support for custom error messages per API endpoint
2. **Error Logging**: Could integrate with analytics/logging services
3. **Retry Logic**: Could add automatic retry for certain error types
4. **Offline Handling**: Could enhance offline mode error handling

## Support

For questions about the global error handling system, refer to this documentation or examine the implementation in `lib/api_handler/dio_client.dart`.