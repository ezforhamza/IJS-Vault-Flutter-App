class UserModel {
  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isEmailVerified,
    required this.provider,
    required this.notificationPreferences,
    required this.subscription,
    required this.billingHistory,
    required this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    return UserModel(
      id: json?['id'] ?? '',
      fullName: json?['fullName'] ?? '',
      image: json?['image'] ?? "",
      email: json?['email'] ?? '',
      role: json?['role'] ?? 'user',
      isEmailVerified: json?['isEmailVerified'] ?? false,
      provider: json?['provider'] ?? '',
      billingHistory: json?['billingHistory'] ?? <dynamic>[],
      notificationPreferences: NotificationPreferencesModel.fromJson(
        json?['notificationPreferences'],
      ),
      subscription: SubscriptionModel.fromJson(json?['subscription']),
    );
  }
  final String id;
  final String fullName;
  final String email;
  final String image;
  final String role;
  final bool isEmailVerified;
  final String provider;
  final NotificationPreferencesModel notificationPreferences;
  final SubscriptionModel subscription;
  final List<dynamic> billingHistory;

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? image,
    String? role,
    bool? isEmailVerified,
    String? provider,
    NotificationPreferencesModel? notificationPreferences,
    SubscriptionModel? subscription,
    List<dynamic>? billingHistory,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      image: image ?? this.image,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      provider: provider ?? this.provider,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      subscription: subscription ?? this.subscription,
      billingHistory: billingHistory ?? this.billingHistory,
    );
  }
}

/* -------------------------------------------------------------------------- */

class NotificationPreferencesModel {
  NotificationPreferencesModel({
    required this.reminders,
    required this.linkedUsersActivity,
    required this.inviteNotifications,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic>? json) {
    return NotificationPreferencesModel(
      reminders: json?['reminders'] ?? false,
      linkedUsersActivity: json?['linkedUsersActivity'] ?? false,
      inviteNotifications: json?['inviteNotifications'] ?? false,
    );
  }
  final bool reminders;
  final bool linkedUsersActivity;
  final bool inviteNotifications;

  NotificationPreferencesModel copyWith({
    bool? reminders,
    bool? linkedUsersActivity,
    bool? inviteNotifications,
  }) {
    return NotificationPreferencesModel(
      reminders: reminders ?? this.reminders,
      linkedUsersActivity: linkedUsersActivity ?? this.linkedUsersActivity,
      inviteNotifications: inviteNotifications ?? this.inviteNotifications,
    );
  }
}

/* -------------------------------------------------------------------------- */

class SubscriptionModel {
  SubscriptionModel({
    required this.plan,
    required this.storageLimit,
    required this.storageUsed,
    required this.autoRenew,
    required this.features,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic>? json) {
    return SubscriptionModel(
      plan: json?['plan'] ?? 'free',
      storageLimit: json?['storageLimit'] ?? 0,
      storageUsed: json?['storageUsed'] ?? 0,
      autoRenew: json?['autoRenew'] ?? false,
      features: SubscriptionFeaturesModel.fromJson(json?['features']),
    );
  }
  final String plan;
  final int storageLimit;
  final int storageUsed;
  final bool autoRenew;
  final SubscriptionFeaturesModel features;
}

/* -------------------------------------------------------------------------- */

class SubscriptionFeaturesModel {
  SubscriptionFeaturesModel({
    required this.maxFileSize,
    required this.canShare,
    required this.canSetReminders,
    required this.maxSharedUsers,
  });

  factory SubscriptionFeaturesModel.fromJson(Map<String, dynamic>? json) {
    return SubscriptionFeaturesModel(
      maxFileSize: json?['maxFileSize'] ?? 0,
      canShare: json?['canShare'] ?? false,
      canSetReminders: json?['canSetReminders'] ?? false,
      maxSharedUsers: json?['maxSharedUsers'] ?? 0,
    );
  }
  final int maxFileSize;
  final bool canShare;
  final bool canSetReminders;
  final int maxSharedUsers;
}

/* -------------------------------------------------------------------------- */

class TokensModel {
  TokensModel({required this.access, required this.refresh});

  factory TokensModel.fromJson(Map<String, dynamic>? json) {
    return TokensModel(
      access: TokenModel.fromJson(json?['access']),
      refresh: TokenModel.fromJson(json?['refresh']),
    );
  }
  final TokenModel access;
  final TokenModel refresh;
}

/* -------------------------------------------------------------------------- */

class TokenModel {
  TokenModel({required this.token, required this.expires});

  factory TokenModel.fromJson(Map<String, dynamic>? json) {
    return TokenModel(
      token: json?['token'] ?? '',
      expires: json?['expires'] ?? '',
    );
  }
  final String token;
  final String expires;
}
