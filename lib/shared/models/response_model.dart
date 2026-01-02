class ApiResponse {
  final bool status;
  final String message;
  final dynamic data;

  ApiResponse({required this.status, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
  // ✅ Add this to fix the error
  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data};
  }
}
