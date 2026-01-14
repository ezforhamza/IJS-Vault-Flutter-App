class LegalPagesResponse {
  LegalPagesResponse({required this.pages});

  factory LegalPagesResponse.fromJson(Map<String, dynamic> json) {
    return LegalPagesResponse(
      pages: (json['pages'] as List<dynamic>?)
              ?.map((dynamic e) => LegalPageModel.fromJson(e))
              .toList() ??
          <LegalPageModel>[],
    );
  }
  final List<LegalPageModel> pages;
}

class LegalPageModel {
  LegalPageModel({
    required this.type,
    required this.title,
    required this.content,
    required this.version,
    this.updatedAt,
  });

  factory LegalPageModel.fromJson(Map<String, dynamic> json) {
    return LegalPageModel(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      version: json['version'] ?? '1.0',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  final String type;
  final String title;
  final String content;
  final String version;
  final DateTime? updatedAt;

  /// Get display title based on type
  String get displayTitle {
    switch (type) {
      case 'privacy_policy':
        return 'Privacy Policy';
      case 'terms_of_service':
        return 'Terms of Service';
      case 'cookie_policy':
        return 'Cookie Policy';
      case 'disclaimer':
        return 'Disclaimer';
      case 'refund_policy':
        return 'Refund Policy';
      default:
        return title;
    }
  }
}
