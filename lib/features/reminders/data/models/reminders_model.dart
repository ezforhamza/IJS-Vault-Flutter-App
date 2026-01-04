class ReminderResponseModel {
  ReminderResponseModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ReminderResponseModel.fromJson(Map<String, dynamic> json) {
    return ReminderResponseModel(
      success: json['success'] ?? false,
      data: ReminderData.fromJson(json['data'] ?? <String, dynamic>{}),
      message: json['message'] ?? '',
    );
  }
  final bool success;
  final ReminderData data;
  final String message;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'success': success,
    'data': data.toJson(),
    'message': message,
  };
}

class ReminderData {
  ReminderData({required this.reminders, required this.pagination});

  factory ReminderData.fromJson(Map<String, dynamic> json) {
    return ReminderData(
      reminders: (json['reminders'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => ReminderItemModel.fromJson(e ?? <String, dynamic>{}))
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] ?? <String, dynamic>{},
      ),
    );
  }
  final List<ReminderItemModel> reminders;
  final Pagination pagination;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'reminders': reminders.map((ReminderItemModel e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
}

class ReminderItemModel {
  factory ReminderItemModel.fromJson(Map<String, dynamic> json) {
    return ReminderItemModel(
      status: json['status'] ?? '',
      parentId: json['parentId'],
      notificationSent: json['notificationSent'] ?? false,
      emailSent: json['emailSent'] ?? false,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      itemId: ReminderItemId.fromJson(json['itemId'] ?? <String, dynamic>{}),
      userId: ReminderUserId.fromJson(json['userId'] ?? <String, dynamic>{}),
      itemName: json['itemName'] ?? '',
      itemType: json['itemType'] ?? '',
      id: json['id'] ?? '',
    );
  }
  ReminderItemModel({
    required this.status,
    this.parentId,
    required this.notificationSent,
    required this.emailSent,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.itemId,
    required this.userId,
    required this.itemName,
    required this.itemType,
    required this.id,
  });
  final String status;
  final String? parentId;
  final bool notificationSent;
  final bool emailSent;
  final String title;
  final String description;
  final String date;
  final String time;
  final ReminderItemId itemId;
  final ReminderUserId userId;
  final String itemName;
  final String itemType;
  final String id;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'status': status,
    'parentId': parentId,
    'notificationSent': notificationSent,
    'emailSent': emailSent,
    'title': title,
    'description': description,
    'date': date,
    'time': time,
    'itemId': itemId.toJson(),
    'userId': userId.toJson(),
    'itemName': itemName,
    'itemType': itemType,
    'id': id,
  };
}

class ReminderItemId {
  ReminderItemId({required this.name, required this.type, required this.id});

  factory ReminderItemId.fromJson(Map<String, dynamic> json) {
    return ReminderItemId(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      id: json['id'] ?? '',
    );
  }
  final String name;
  final String type;
  final String id;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'type': type,
    'id': id,
  };
}

class ReminderUserId {
  ReminderUserId({
    required this.fullName,
    required this.email,
    required this.id,
  });

  factory ReminderUserId.fromJson(Map<String, dynamic> json) {
    return ReminderUserId(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      id: json['id'] ?? '',
    );
  }
  final String fullName;
  final String email;
  final String id;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'fullName': fullName,
    'email': email,
    'id': id,
  };
}

class Pagination {
  Pagination({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
    this.nextPage,
    this.prevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
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

  Map<String, dynamic> toJson() => <String, dynamic>{
    'page': page,
    'limit': limit,
    'totalCount': totalCount,
    'totalPages': totalPages,
    'hasNextPage': hasNextPage,
    'hasPrevPage': hasPrevPage,
    'nextPage': nextPage,
    'prevPage': prevPage,
  };
}
