import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/my_vault_widget.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/shared_with_me.dart';
import 'package:ijs_vault/features/reminders/presentation/screens/reminders_screen.dart';
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

        appBar: CustomProfileAppBar(
          textTheme: Theme.of(context).textTheme,
          isCentre: false,
        ),

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
                    SharedWithMe(),
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
