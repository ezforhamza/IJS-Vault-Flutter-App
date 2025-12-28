import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/my_vault.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';

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
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: AppSizes.horizontalPadding,
          child: Column(
            spacing: 25,
            children: <Widget>[
              const SizedBox(height: 0),

              // Build Header
              ProfileHeader(textTheme: textTheme),

              // Search Bar
              _buildSearchField(),

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

  TextFormField _buildSearchField() {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search',
        // dark field fill color
        isDense: true, // reduces height
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),

        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Image.asset(AppImages.search, width: 18, height: 18),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 18,
          minHeight: 18,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1.2,
          ), // remove default border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: const BorderSide(color: Colors.white, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildGradientTabBar(bool isDark) {
    final MyVaultController controller = Get.find<MyVaultController>();

    return Container(
      height: 45,
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

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

    return Row(
      children: <Widget>[
        // Image
        const ProfilePictureWidget(
          radius: 15,
          imageUrl: "https://randomuser.me/api/portraits/men/1.jpg",
        ),
        const SizedBox(width: 5),

        // Name
        Text(
          'Hello, John Marston',
          style: textTheme.labelLarge!.copyWith(fontSize: 16),
        ),
        const Spacer(),

        // Icon
        SvgPicture.asset(
          AppImages.bell,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ],
    );
  }
}
