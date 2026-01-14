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
              ?.map((dynamic e) => NotificationModel.fromJson(e))
              .toList() ??
          <NotificationModel>[],
      pagination: NotificationPaginationModel.fromJson(
        json['pagination'] ?? <String, dynamic>{},
      ),
    );
  }
  final List<NotificationModel> notifications;
  final NotificationPaginationModel pagination;
}

class NotificationModel {
  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.message,
    required this.isRead,
    required this.userId,
    this.itemId,
    this.itemName,
    this.fromUser,
    this.data,
    required this.priority,
    this.icon,
    this.actionUrl,
    this.sentAt,
    this.timestamp,
    this.channels,
    this.fcmSent,
    this.emailSent,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      userId: json['userId'] ?? '',
      itemId: json['itemId'],
      itemName: json['itemName'],
      fromUser: json['fromUser'] != null
          ? NotificationFromUserModel.fromJson(json['fromUser'])
          : null,
      data: json['data'] != null
          ? NotificationDataModel.fromJson(json['data'])
          : null,
      priority: json['priority'] ?? 'normal',
      icon: json['icon'],
      actionUrl: json['actionUrl'],
      sentAt: json['sentAt'] != null ? DateTime.tryParse(json['sentAt']) : null,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'])
          : null,
      channels: json['channels'] != null
          ? NotificationChannelsModel.fromJson(json['channels'])
          : null,
      fcmSent: json['fcmSent'],
      emailSent: json['emailSent'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  /// Create from FCM RemoteMessage data
  factory NotificationModel.fromFCM(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['notificationId'] ?? data['id'] ?? '',
      type: data['type'] ?? 'system',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      message: data['message'] ?? data['body'] ?? '',
      isRead: false,
      userId: data['userId'] ?? '',
      itemId: data['itemId'],
      itemName: data['itemName'],
      fromUser: data['fromUserId'] != null
          ? NotificationFromUserModel(
              id: data['fromUserId'],
              fullName: data['fromUserName'] ?? '',
              email: data['fromUserEmail'],
              image: data['fromUserImage'],
            )
          : null,
      data: NotificationDataModel.fromJson(data),
      priority: data['priority'] ?? 'normal',
      icon: data['icon'],
      actionUrl: data['actionUrl'],
      sentAt: DateTime.now(),
      timestamp: DateTime.now(),
      channels: null,
      fcmSent: true,
      emailSent: false,
    );
  }

  final String id;
  final String type;
  final String title;
  final String body;
  final String message;
  final bool isRead;
  final String userId;
  final String? itemId;
  final String? itemName;
  final NotificationFromUserModel? fromUser;
  final NotificationDataModel? data;
  final String priority;
  final String? icon;
  final String? actionUrl;
  final DateTime? sentAt;
  final DateTime? timestamp;
  final NotificationChannelsModel? channels;
  final bool? fcmSent;
  final bool? emailSent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Get the icon data based on notification type
  String get iconName {
    switch (type) {
      case 'share':
        return 'share';
      case 'edit':
        return 'edit';
      case 'delete':
        return 'delete';
      case 'move':
        return 'move';
      case 'unshare':
        return 'unshare';
      case 'reminder':
        return 'reminder';
      case 'admin_notification':
        return 'announcement';
      default:
        return 'bell';
    }
  }

  /// Check if notification is high priority
  bool get isHighPriority => priority == 'high' || priority == 'critical';

  /// Copy with updated read status
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      message: message,
      isRead: isRead ?? this.isRead,
      userId: userId,
      itemId: itemId,
      itemName: itemName,
      fromUser: fromUser,
      data: data,
      priority: priority,
      icon: icon,
      actionUrl: actionUrl,
      sentAt: sentAt,
      timestamp: timestamp,
      channels: channels,
      fcmSent: fcmSent,
      emailSent: emailSent,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class NotificationFromUserModel {
  NotificationFromUserModel({
    required this.id,
    required this.fullName,
    this.email,
    this.image,
  });

  factory NotificationFromUserModel.fromJson(Map<String, dynamic> json) {
    return NotificationFromUserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'],
      image: json['image'],
    );
  }
  final String id;
  final String fullName;
  final String? email;
  final String? image;
}

class NotificationDataModel {
  NotificationDataModel({
    this.type,
    this.itemId,
    this.fromUserId,
    this.role,
    this.isTestNotification,
    this.adminNotificationId,
    this.notificationType,
    this.isAdminNotification,
  });

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationDataModel(
      type: json['type'],
      itemId: json['itemId'],
      fromUserId: json['fromUserId'],
      role: json['role'],
      isTestNotification: json['isTestNotification'],
      adminNotificationId: json['adminNotificationId'],
      notificationType: json['notificationType'],
      isAdminNotification: json['isAdminNotification'],
    );
  }
  final String? type;
  final String? itemId;
  final String? fromUserId;
  final String? role;
  final bool? isTestNotification;
  final String? adminNotificationId;
  final String? notificationType;
  final bool? isAdminNotification;
}

class NotificationChannelsModel {
  NotificationChannelsModel({
    required this.push,
    required this.email,
    required this.inApp,
  });

  factory NotificationChannelsModel.fromJson(Map<String, dynamic> json) {
    return NotificationChannelsModel(
      push: json['push'] ?? false,
      email: json['email'] ?? false,
      inApp: json['inApp'] ?? true,
    );
  }
  final bool push;
  final bool email;
  final bool inApp;
}

class NotificationPaginationModel {
  NotificationPaginationModel({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
    this.nextPage,
    this.prevPage,
  });

  factory NotificationPaginationModel.fromJson(Map<String, dynamic> json) {
    return NotificationPaginationModel(
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
