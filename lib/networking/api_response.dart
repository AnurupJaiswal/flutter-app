class ApiResponse<T> {
  final bool success;
  final int? statusCode;
  final T? data;
  final String message;
  final String? errorCode;

  ApiResponse({
    required this.success,
    this.statusCode,
    this.data,
    String? message,
    this.errorCode,
  }) : message = message ?? (success ? "Success" : "An error occurred");

  bool get isSuccess => success;

  factory ApiResponse.success({
    T? data,
    int? statusCode,
    String? message,
    String? errorCode,
  }) {
    return ApiResponse<T>(
      success: true,
      statusCode: statusCode ?? 200,
      data: data,
      message: message ?? "Success",
      errorCode: errorCode,
    );
  }

  factory ApiResponse.error({
    String? message,
    int? statusCode,
    T? data,
    String? errorCode,
  }) {
    return ApiResponse<T>(
      success: false,
      statusCode: statusCode ?? 500,
      message: message ?? "An error occurred",
      data: data,
      errorCode: errorCode,
    );
  }
}
