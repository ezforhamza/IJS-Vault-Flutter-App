import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/utils.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/core/controllers/fcm_controller.dart';
import 'package:ijs_vault/features/auth/presentation/screens/login_screen.dart';
import 'package:ijs_vault/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:ijs_vault/features/settings/presentation/screens/activity_log_screen.dart';
import 'package:ijs_vault/features/settings/presentation/screens/change_password_screen.dart';
import 'package:ijs_vault/features/settings/presentation/screens/notification_screen.dart';
import 'package:ijs_vault/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:ijs_vault/features/settings/presentation/screens/profile_setup.dart';
import 'package:ijs_vault/features/settings/presentation/screens/terms_and_conditions_screen.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/dialoge.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/profile_widget.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/setting_option_widget.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;
    return SafeArea(
      child: Scaffold(
        // bottomNavigationBar: Container(
        //   height: 60,
        //   color: AppColors.scaffoldBackgroundColor,
        // ),
        appBar: CustomProfileAppBar(
          textTheme: Theme.of(context).textTheme,
          isCentre: true,
          title: 'Settings',
        ),
        body: Padding(
          padding: AppSizes.horizontalPadding,
          child: SingleChildScrollView(
            child: Column(
              spacing: 20,
              children: <Widget>[
                const SizedBox(),
                // _buildSearchField(isDarkMode)
                // Profile Container
                GestureDetector(
                  onTap: () {
                    Get.to(() => const ProfileSetupScreen());
                  },
                  child: const ProfileWIdget(),
                ),
                //
                const SettingOptionWidget(
                  text: 'Dark Mode',
                  icon: AppImages.darkmode,
                  isSwitch: true,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const ActivityLogScreen());
                  },
                  child: const SettingOptionWidget(
                    text: 'Activity Log',
                    icon: AppImages.activitylog,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const ChangePasswordScreen());
                  },
                  child: const SettingOptionWidget(
                    text: 'Change Password',
                    icon: AppImages.changepassword,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const NotificationScreen());
                  },
                  child: const SettingOptionWidget(
                    text: 'Notification',
                    icon: AppImages.notification,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const PrivacyPolicyScreen());
                  },
                  child: const SettingOptionWidget(
                    text: 'Privacy Policy',
                    icon: AppImages.privacy,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const TermsAndConditionsScreen());
                  },
                  child: const SettingOptionWidget(
                    text: 'Terms & Conditions',
                    icon: AppImages.terms,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: 'Success',
                      barrierColor: Colors.black.withOpacity(0.4),
                      transitionDuration: const Duration(milliseconds: 350),
                      pageBuilder:
                          (
                            BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation,
                          ) {
                            return Center(
                              child: ConfirmationDialogue(
                                onTap: () async {
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  Get.find<FCMController>()
                                      .unregisterFCMToken();
                                  prefs.clear();
                                  Get.offAll(() => const LoginScreen());
                                },
                                h: ScreenHelper.height(context),
                                theme: Theme.of(context).textTheme,
                                title: 'Logout?',
                                subtitle:
                                    'Do you really want to logout this account?',
                                image: AppImages.confirmlogout,
                                buttonText: 'Logout',
                              ),
                            );
                          },
                      transitionBuilder:
                          (
                            BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation,
                            Widget child,
                          ) {
                            final CurvedAnimation curvedAnimation =
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutBack,
                                );

                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: curvedAnimation,
                                child: child,
                              ),
                            );
                          },
                    );
                  },
                  child: const SettingOptionWidget(
                    text: 'Logout',
                    icon: AppImages.logout,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: 'Success',
                      barrierColor: Colors.black.withOpacity(0.4),
                      transitionDuration: const Duration(milliseconds: 350),
                      pageBuilder:
                          (
                            BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation,
                          ) {
                            return Center(
                              child: ConfirmationDialogue(
                                onTap: () {},
                                h: ScreenHelper.height(context),
                                theme: Theme.of(context).textTheme,
                                title: 'Delete?',
                                subtitle:
                                    'Do you really want to delete this account?',
                                image: AppImages.confirmdelete,
                                buttonText: 'Delete',
                              ),
                            );
                          },
                      transitionBuilder:
                          (
                            BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation,
                            Widget child,
                          ) {
                            final CurvedAnimation curvedAnimation =
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutBack,
                                );

                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: curvedAnimation,
                                child: child,
                              ),
                            );
                          },
                    );
                  },

                  child: const SettingOptionWidget(
                    text: 'Delete Account',
                    icon: AppImages.delaccount,
                  ),
                ),

                // Rminders
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const SettingsScreenAppBar({super.key, required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,

      // LEFT WIDGET
      leading: const Padding(
        padding: EdgeInsets.only(left: 12, top: 12, bottom: 12),
        child: ProfilePictureWidget(
          radius: 15,
          imageUrl: "https://randomuser.me/api/portraits/men/1.jpg",
        ),
      ),

      // TITLE
      title: Text(
        'Settings',
        style: textTheme.labelLarge!.copyWith(fontSize: 16),
      ),

      // RIGHT ACTION
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SvgPicture.asset(
            AppImages.bell,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  /// Required for AppBar height
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
