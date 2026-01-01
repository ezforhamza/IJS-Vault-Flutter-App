import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/utils.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/settings/presentation/screens/profile_setup.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/profile_widget.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/setting_option_widget.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = ScreenHelper.isdarkMode(context);
    return SafeArea(
      child: Scaffold(
        // bottomNavigationBar: Container(
        //   height: 60,
        //   color: AppColors.scaffoldBackgroundColor,
        // ),
        appBar: SettingsScreenAppBar(textTheme: textTheme),
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
                ),
                const SettingOptionWidget(
                  text: 'Activity Log',
                  icon: AppImages.activitylog,
                ),
                const SettingOptionWidget(
                  text: 'Change Password',
                  icon: AppImages.changepassword,
                ),
                const SettingOptionWidget(
                  text: 'Notification',
                  icon: AppImages.notification,
                ),
                const SettingOptionWidget(
                  text: 'Privacy Policy',
                  icon: AppImages.privacy,
                ),
                const SettingOptionWidget(
                  text: 'Terms & Conditions',
                  icon: AppImages.terms,
                ),
                const SettingOptionWidget(
                  text: 'Logout',
                  icon: AppImages.logout,
                ),
                const SettingOptionWidget(
                  text: 'Delete Account',
                  icon: AppImages.delaccount,
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
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

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
