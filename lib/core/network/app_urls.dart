class AppUrls {
  static const String baseUrl = 'https://ijsvault.codecoytechnologies.live/v1/';

  // AUTH
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh-tokens';
  static const String deleteAccount = 'auth/account';
  static const String forgotPassword = 'auth/forgot-password';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resendVerificationCode = 'auth/resend-code';
  static const String resetPassword = 'auth/reset-password';
  static const String changePassword = 'auth/change-password';
  static const String sendPasswordChangeOtp = 'auth/send-password-change-otp';
  static const String uploadPfp = 'users/profile-picture';
  static const String updateusernameandphone = 'users/profile';
  static const String searchUserForLinking = 'users/search-for-linking';
  static const String getLinkedUsers = 'users/linked/details';
  static const String registerFCM = 'fcm/register';
  static const String unregisterFCM = 'fcm/unregister';
  static const String getAllNotifications = 'notifications';
  static const String updateNotificationPrefs =
      'users/notification-preferences';

  // Vault
  static const String createFolder = 'vault/folders';
  static const String getVaultItems = 'vault/items';
  // static const String uploadFile = 'vault/files';
  static const String renameItem = 'vault/items'; // /{id}
  static const String moveItem = 'vault/items';
  static const String deleteItem = 'vault/items'; // /{id}
  static const String uploadlessThan100 = 'vault/upload'; // /{id}

  // Shared Vault
  static const String getSharedVault = 'vault/shared';

  // Rminders
  static const String createreminders = 'reminders';
  static const String auditLogs = 'audit-logs';
}
