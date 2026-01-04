import 'package:ijs_vault/features/reminders/data/models/reminders_model.dart';

class ActivityLogResponseModel {
  ActivityLogResponseModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ActivityLogResponseModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogResponseModel(
      success: json['success'] ?? false,
      data: ActivityLogData.fromJson(json['data'] ?? <String, dynamic>{}),
      message: json['message'] ?? '',
    );
  }
  final bool success;
  final ActivityLogData data;
  final String message;
}

class ActivityLogData {
  ActivityLogData({required this.logs, required this.pagination});

  factory ActivityLogData.fromJson(Map<String, dynamic> json) {
    return ActivityLogData(
      logs: (json['logs'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => ActivityLogItem.fromJson(e ?? <String, dynamic>{}))
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] ?? <String, dynamic>{},
      ),
    );
  }
  final List<ActivityLogItem> logs;
  final Pagination pagination;
}

class ActivityLogItem {
  ActivityLogItem({
    required this.performedBy,
    required this.action,
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.details,
    required this.ownerId,
    required this.id,
    this.createdAt,
  });

  factory ActivityLogItem.fromJson(Map<String, dynamic> json) {
    return ActivityLogItem(
      performedBy: PerformedBy.fromJson(
        json['performedBy'] ?? <String, dynamic>{},
      ),
      action: json['action'] ?? '',
      itemId: json['itemId'] ?? '',
      itemName: json['itemName'] ?? '',
      itemType: json['itemType'] ?? '',
      details: LogDetails.fromJson(json['details'] ?? <String, dynamic>{}),
      ownerId: json['ownerId'] ?? '',
      id: json['id'] ?? '',
      createdAt: json['createdAt'],
    );
  }
  final PerformedBy performedBy;
  final String action;
  final String itemId;
  final String itemName;
  final String itemType;
  final LogDetails details;
  final String ownerId;
  final String id;
  final String? createdAt;
}

class PerformedBy {
  PerformedBy({required this.name, required this.email, required this.id});

  factory PerformedBy.fromJson(Map<String, dynamic> json) {
    // Sometimes 'id' is an object in the JSON provided?
    // "performedBy": { "id": { ... }, "name": "Abdullah", ... }
    // OR "performedBy": { "id": "...", ... }
    // The JSON sample shows `id` as an object inside `performedBy`.
    // Let's handle string or object for `id` just in case, but rely on name/email at top level of performedBy.
    return PerformedBy(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      id: json['id'] is Map ? json['id']['id'] ?? '' : json['id'].toString(),
    );
  }
  final String name;
  final String email;
  final String id;
}

class LogDetails {
  LogDetails({
    this.size,
    this.mimeType,
    this.parentId,
    this.oldParentId,
    this.newParentId,
  });

  factory LogDetails.fromJson(Map<String, dynamic> json) {
    return LogDetails(
      size: json['size'],
      mimeType: json['mimeType'],
      parentId: json['parentId'],
      oldParentId: json['oldParentId'],
      newParentId: json['newParentId'],
    );
  }
  final int? size;
  final String? mimeType;
  final String? parentId;
  final String? oldParentId;
  final String? newParentId;
}
