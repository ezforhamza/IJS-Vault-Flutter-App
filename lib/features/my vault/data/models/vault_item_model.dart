class ItemsResponseModel {
  ItemsResponseModel({required this.items, required this.pagination});

  factory ItemsResponseModel.fromJson(Map<String, dynamic>? json) {
    return ItemsResponseModel(
      items: (json?['items'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => ItemModel.fromJson(e))
          .toList(),
      pagination: PaginationModel.fromJson(json?['pagination']),
    );
  }

  final List<ItemModel> items;
  final PaginationModel pagination;
}

/* -------------------------------------------------------------------------- */

class ItemModel {
  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.parentId,
    required this.isLocked,
    required this.owner,
    required this.linkedUsers,
    required this.createdAt,
    required this.updatedAt,
    required this.breadcrumb,
  });

  factory ItemModel.fromJson(Map<String, dynamic>? json) {
    return ItemModel(
      id: json?['id'] ?? '',
      name: json?['name'] ?? '',
      description: json?['description'] ?? '',
      type: json?['type'] ?? '',
      parentId: json?['parentId'],
      isLocked: json?['isLocked'] ?? false,
      owner: OwnerModel.fromJson(json?['ownerId']),
      linkedUsers: json?['linkedUsers'] ?? <dynamic>[],
      createdAt: json?['createdAt'] ?? '',
      updatedAt: json?['updatedAt'] ?? '',
      breadcrumb: BreadcrumbModel.fromJson(json?['breadcrumb']),
    );
  }

  final String id;
  final String name;
  final String description;
  final String type;
  final dynamic parentId;
  final bool isLocked;
  final OwnerModel owner;
  final List<dynamic> linkedUsers;
  final String createdAt;
  final String updatedAt;
  final BreadcrumbModel breadcrumb;
}

/* -------------------------------------------------------------------------- */

class OwnerModel {
  OwnerModel({required this.id, required this.fullName, required this.email});

  factory OwnerModel.fromJson(Map<String, dynamic>? json) {
    return OwnerModel(
      id: json?['id'] ?? '',
      fullName: json?['fullName'] ?? '',
      email: json?['email'] ?? '',
    );
  }

  final String id;
  final String fullName;
  final String email;
}

/* -------------------------------------------------------------------------- */

class BreadcrumbModel {
  BreadcrumbModel({required this.path, required this.pathString});

  factory BreadcrumbModel.fromJson(Map<String, dynamic>? json) {
    return BreadcrumbModel(
      path: (json?['path'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => BreadcrumbPathModel.fromJson(e))
          .toList(),
      pathString: json?['pathString'] ?? '',
    );
  }

  final List<BreadcrumbPathModel> path;
  final String pathString;
}

/* -------------------------------------------------------------------------- */

class BreadcrumbPathModel {
  BreadcrumbPathModel({required this.id, required this.name});

  factory BreadcrumbPathModel.fromJson(Map<String, dynamic>? json) {
    return BreadcrumbPathModel(id: json?['id'], name: json?['name'] ?? '');
  }

  final dynamic id;
  final String name;
}

/* -------------------------------------------------------------------------- */

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

  factory PaginationModel.fromJson(Map<String, dynamic>? json) {
    return PaginationModel(
      page: json?['page'] ?? 1,
      limit: json?['limit'] ?? 0,
      totalCount: json?['totalCount'] ?? 0,
      totalPages: json?['totalPages'] ?? 0,
      hasNextPage: json?['hasNextPage'] ?? false,
      hasPrevPage: json?['hasPrevPage'] ?? false,
      nextPage: json?['nextPage'],
      prevPage: json?['prevPage'],
    );
  }

  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
  final dynamic nextPage;
  final dynamic prevPage;
}
