class LinkedUsersResponseModel {
  LinkedUsersResponseModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory LinkedUsersResponseModel.fromJson(Map<String, dynamic> json) {
    return LinkedUsersResponseModel(
      success: json['success'] ?? false,
      data: LinkedUsersDataModel.fromJson(json['data'] ?? <String, dynamic>{}),
      message: json['message'] ?? '',
    );
  }
  final bool success;
  final LinkedUsersDataModel data;
  final String message;
}

class LinkedUsersDataModel {
  LinkedUsersDataModel({required this.users, required this.summary});

  factory LinkedUsersDataModel.fromJson(Map<String, dynamic> json) {
    return LinkedUsersDataModel(
      users: (json['users'] as List? ?? <dynamic>[])
          .map((e) => LinkedUserModel.fromJson(e))
          .toList(),
      summary: LinkedUsersSummaryModel.fromJson(
        json['summary'] ?? <String, dynamic>{},
      ),
    );
  }
  final List<LinkedUserModel> users;
  final LinkedUsersSummaryModel summary;
}

class LinkedUserModel {
  LinkedUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.image,
    required this.primaryRole,
    required this.roles,
    required this.totalSharedCount,
    this.lastSharedAt,
    required this.sharedItems,
  });

  factory LinkedUserModel.fromJson(Map<String, dynamic> json) {
    return LinkedUserModel(
      id: json['id'] ?? json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? "",
      primaryRole: json['primaryRole'] ?? '',
      roles: List<String>.from(json['roles'] ?? <dynamic>[]),
      totalSharedCount: json['totalSharedCount'] ?? 0,
      lastSharedAt: json['lastSharedAt'] != null
          ? DateTime.tryParse(json['lastSharedAt'])
          : null,
      sharedItems: SharedItemsModel.fromJson(
        json['sharedItems'] ?? <String, dynamic>{},
      ),
    );
  }
  final String id;
  final String fullName;
  final String email;
  final String image;
  final String primaryRole;
  final List<String> roles;
  final int totalSharedCount;
  final DateTime? lastSharedAt;
  final SharedItemsModel sharedItems;
}

class SharedItemsModel {
  SharedItemsModel({required this.folders, required this.files});

  factory SharedItemsModel.fromJson(Map<String, dynamic> json) {
    return SharedItemsModel(
      folders: (json['folders'] as List? ?? <dynamic>[])
          .map((e) => SharedFolderModel.fromJson(e))
          .toList(),
      files: (json['files'] as List? ?? <dynamic>[])
          .map((e) => SharedFileModel.fromJson(e))
          .toList(),
    );
  }
  final List<SharedFolderModel> folders;
  final List<SharedFileModel> files;
}

class SharedFolderModel {
  SharedFolderModel({
    required this.id,
    required this.name,
    required this.role,
    this.sharedAt,
    this.parentId,
    this.parentName,
    this.color,
  });

  factory SharedFolderModel.fromJson(Map<String, dynamic> json) {
    return SharedFolderModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      sharedAt: json['sharedAt'] != null
          ? DateTime.tryParse(json['sharedAt'])
          : null,
      parentId: json['parentId'],
      parentName: json['parentName'],
      color: json['color'],
    );
  }
  final String id;
  final String name;
  final String role;
  final DateTime? sharedAt;
  final String? parentId;
  final String? parentName;
  final String? color;
}

class SharedFileModel {
  SharedFileModel({
    required this.id,
    required this.name,
    required this.role,
    this.sharedAt,
    this.parentId,
    this.parentName,
    this.fileType,
  });

  factory SharedFileModel.fromJson(Map<String, dynamic> json) {
    return SharedFileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      sharedAt: json['sharedAt'] != null
          ? DateTime.tryParse(json['sharedAt'])
          : null,
      parentId: json['parentId'],
      parentName: json['parentName'],
      fileType: json['fileType'],
    );
  }
  final String id;
  final String name;
  final String role;
  final DateTime? sharedAt;
  final String? parentId;
  final String? parentName;
  final String? fileType;
}

class LinkedUsersSummaryModel {
  LinkedUsersSummaryModel({
    required this.totalLinkedUsers,
    required this.totalSharedItems,
  });

  factory LinkedUsersSummaryModel.fromJson(Map<String, dynamic> json) {
    return LinkedUsersSummaryModel(
      totalLinkedUsers: json['totalLinkedUsers'] ?? 0,
      totalSharedItems: json['totalSharedItems'] ?? 0,
    );
  }
  final int totalLinkedUsers;
  final int totalSharedItems;
}
