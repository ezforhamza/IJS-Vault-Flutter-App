class ApiResponse {
  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['success'] == true
          ? (json['message'] ?? '') // optional success message
          : (json['error'] != null ? json['error']['message'] ?? '' : ''),
      data: json['data'],
    );
  }

  final bool success;
  final String message;
  final dynamic data;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'message': message,
      'data': data,
    };
  }
}
