// notifications_response_model.dart

class NotificationsResponse {
  NotificationsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      success: json['success'] ?? false,
      data: NotificationsData.fromJson(json['data'] ?? <String, dynamic>{}),
      message: json['message'] ?? '',
    );
  }
  final bool success;
  final NotificationsData data;
  final String message;
}

class NotificationsData {
  NotificationsData({required this.notifications, required this.pagination});

  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    return NotificationsData(
      notifications:
          (json['notifications'] as List<dynamic>?)
              ?.map((e) => NotificationModel.fromJson(e))
              .toList() ??
          <NotificationModel>[],
      pagination: PaginationModel.fromJson(
        json['pagination'] ?? <String, dynamic>{},
      ),
    );
  }
  final List<NotificationModel> notifications;
  final PaginationModel pagination;
}

class NotificationModel {
  NotificationModel({
    required this.fromUser,
    required this.isRead,
    required this.type,
    required this.title,
    required this.message,
    required this.userId,
    required this.itemId,
    required this.itemName,
    required this.id,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      fromUser: FromUserModel.fromJson(json['fromUser'] ?? <String, dynamic>{}),
      isRead: json['isRead'] ?? false,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      userId: json['userId'] ?? '',
      itemId: json['itemId'] ?? '',
      itemName: json['itemName'] ?? '',
      id: json['id'] ?? '',
    );
  }
  final FromUserModel fromUser;
  final bool isRead;
  final String type;
  final String title;
  final String message;
  final String userId;
  final String itemId;
  final String itemName;
  final String id;
}

class FromUserModel {
  FromUserModel({required this.id, required this.fullName});

  factory FromUserModel.fromJson(Map<String, dynamic> json) {
    return FromUserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }
  final String id;
  final String fullName;
}

class PaginationModel {
  PaginationModel({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
    this.nextPage,
    this.prevPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
      nextPage: json['nextPage'],
      prevPage: json['prevPage'],
    );
  }
  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int? nextPage;
  final int? prevPage;
}
