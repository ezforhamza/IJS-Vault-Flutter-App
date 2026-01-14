class ApiResponse {
  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
    this.requiresRelogin = false,
    this.lockedOut = false,
    this.remainingAttempts,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    final dynamic errorData = json['error'];
    final dynamic responseData = json['data'];
    
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['success'] == true
          ? (json['message'] ?? '')
          : (errorData != null ? errorData['message'] ?? '' : (json['message'] ?? '')),
      data: responseData,
      errorCode: errorData != null ? errorData['code'] : null,
      requiresRelogin: responseData != null ? (responseData['requiresRelogin'] ?? false) : false,
      lockedOut: responseData != null ? (responseData['lockedOut'] ?? false) : false,
      remainingAttempts: responseData != null ? responseData['remainingAttempts'] : null,
    );
  }

  final bool success;
  final String message;
  final dynamic data;
  final int? errorCode;
  final bool requiresRelogin;
  final bool lockedOut;
  final int? remainingAttempts;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'message': message,
      'data': data,
      'errorCode': errorCode,
      'requiresRelogin': requiresRelogin,
      'lockedOut': lockedOut,
      'remainingAttempts': remainingAttempts,
    };
  }
}
