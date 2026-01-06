import 'dart:convert';

import 'package:ijs_vault/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String keyUser = 'user';
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyIsFirstTime = 'is_first_time';

  /// ------------------- Save Functions -------------------

  static Future<void> saveUser(UserModel user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String userJson = jsonEncode(<String, Object?>{
      'id': user.id,
      'fullName': user.fullName,
      'email': user.email,
      'role': user.role,
      'isEmailVerified': user.isEmailVerified,
      'provider': user.provider,
      'notificationPreferences': <String, bool>{
        'reminders': user.notificationPreferences.reminders,
        'linkedUsersActivity': user.notificationPreferences.linkedUsersActivity,
        'inviteNotifications': user.notificationPreferences.inviteNotifications,
      },
      'subscription': <String, Object?>{
        'plan': user.subscription.plan,
        'storageLimit': user.subscription.storageLimit,
        'storageUsed': user.subscription.storageUsed,
        'autoRenew': user.subscription.autoRenew,
        'features': <String, Object?>{
          'maxFileSize': user.subscription.features.maxFileSize,
          'canShare': user.subscription.features.canShare,
          'canSetReminders': user.subscription.features.canSetReminders,
          'maxSharedUsers': user.subscription.features.maxSharedUsers,
        },
      },
      'billingHistory': user.billingHistory,
    });

    await prefs.setString(keyUser, userJson);
  }

  static Future<void> saveTokens(TokensModel tokens) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(keyAccessToken, tokens.access.token);
    await prefs.setString(keyRefreshToken, tokens.refresh.token);
  }

  static Future<void> setFirstTime(bool isFirstTime) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsFirstTime, isFirstTime);
  }

  /// ------------------- Get Functions -------------------

  static Future<UserModel?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(keyUser);

    if (userJson == null) return null;

    final Map<String, dynamic> userMap = jsonDecode(userJson);
    return UserModel.fromJson(userMap);
  }

  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyRefreshToken);
  }

  static Future<bool> isFirstTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsFirstTime) ?? true;
  }

  /// ------------------- Clear Functions -------------------

  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(keyUser);
    await prefs.remove(keyAccessToken);
    await prefs.remove(keyRefreshToken);
  }
}
