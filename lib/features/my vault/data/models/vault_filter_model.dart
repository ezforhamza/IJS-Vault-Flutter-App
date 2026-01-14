enum VaultItemType { all, folder, file }

enum VaultFileType { all, document, media, note }

enum VaultSortBy { name, createdAt, updatedAt, size }

enum VaultSortOrder { asc, desc }

class VaultFilter {
  VaultFilter({
    this.type = VaultItemType.all,
    this.fileType = VaultFileType.all,
    this.sortBy = VaultSortBy.name,
    this.sortOrder = VaultSortOrder.asc,
  });

  final VaultItemType type;
  final VaultFileType fileType;
  final VaultSortBy sortBy;
  final VaultSortOrder sortOrder;

  VaultFilter copyWith({
    VaultItemType? type,
    VaultFileType? fileType,
    VaultSortBy? sortBy,
    VaultSortOrder? sortOrder,
  }) {
    return VaultFilter(
      type: type ?? this.type,
      fileType: fileType ?? this.fileType,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool get isDefault =>
      type == VaultItemType.all &&
      fileType == VaultFileType.all &&
      sortBy == VaultSortBy.name &&
      sortOrder == VaultSortOrder.asc;

  int get activeFilterCount {
    int count = 0;
    if (type != VaultItemType.all) count++;
    if (fileType != VaultFileType.all) count++;
    if (sortBy != VaultSortBy.name || sortOrder != VaultSortOrder.asc) count++;
    return count;
  }

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = <String, dynamic>{};

    if (type != VaultItemType.all) {
      params['type'] = type == VaultItemType.folder ? 'folder' : 'file';
    }

    if (type == VaultItemType.file && fileType != VaultFileType.all) {
      params['fileType'] = fileType.name;
    }

    params['sortBy'] = sortBy.name;
    params['sortOrder'] = sortOrder.name;

    return params;
  }

  static VaultFilter defaultFilter() => VaultFilter();
}

extension VaultItemTypeExtension on VaultItemType {
  String get label {
    switch (this) {
      case VaultItemType.all:
        return 'All';
      case VaultItemType.folder:
        return 'Folders';
      case VaultItemType.file:
        return 'Files';
    }
  }

  String get icon {
    switch (this) {
      case VaultItemType.all:
        return 'grid_view';
      case VaultItemType.folder:
        return 'folder';
      case VaultItemType.file:
        return 'description';
    }
  }
}

extension VaultFileTypeExtension on VaultFileType {
  String get label {
    switch (this) {
      case VaultFileType.all:
        return 'All Files';
      case VaultFileType.document:
        return 'Documents';
      case VaultFileType.media:
        return 'Media';
      case VaultFileType.note:
        return 'Notes';
    }
  }
}

extension VaultSortByExtension on VaultSortBy {
  String get label {
    switch (this) {
      case VaultSortBy.name:
        return 'Name';
      case VaultSortBy.createdAt:
        return 'Date Created';
      case VaultSortBy.updatedAt:
        return 'Date Modified';
      case VaultSortBy.size:
        return 'Size';
    }
  }
}
