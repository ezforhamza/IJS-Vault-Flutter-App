import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/my_vault_widget.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';
import 'package:ijs_vault/shared/widgets/search_field.dart';

class MyVaultScreen extends StatefulWidget {
  const MyVaultScreen({super.key});

  @override
  State<MyVaultScreen> createState() => _MyVaultScreenState();
}

class _MyVaultScreenState extends State<MyVaultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = <String>['My Vault', 'Shared with me'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        appBar: ProfileHeader(textTheme: textTheme),

        body: Padding(
          padding: AppSizes.horizontalPadding,
          child: Column(
            spacing: 25,
            children: <Widget>[
              // Build Header

              // Search Bar
              // _buildSearchField(isDarkMode),
              CustomSearchField(isDarkMode: isDarkMode),

              // Gradient TabBar
              _buildGradientTabBar(isDarkMode),

              // TabBar Views
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: const <Widget>[
                    MyVault(),
                    Center(child: Text('Shared with me')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientTabBar(bool isDark) {
    final MyVaultController controller = Get.find<MyVaultController>();

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF494a51) : const Color(0xFFf4f4f4),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: TabBar(
        isScrollable: false,
        controller: _tabController,
        splashBorderRadius: BorderRadius.circular(AppSizes.borderRadius),
        indicator: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.gradient),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,

        unselectedLabelColor: isDark ? Colors.white70 : Colors.black,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        onTap: (int value) {
          print('Tab Tapped $value');
          if (value == 1) {
            controller.showAddButton.value = false;
          } else {
            controller.showAddButton.value = true;
          }
        },
        tabs: tabs.map((String e) => Tab(text: e)).toList(),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget implements PreferredSizeWidget {
  const ProfileHeader({super.key, required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final MyVaultController controller = Get.find<MyVaultController>();

    final bool isDarkMode = Get.isDarkMode;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: false,

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
        ' ${controller.user.value!.fullName}',
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
