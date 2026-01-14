import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/services/upload_manager/upload_progress_overlay.dart';
import 'package:ijs_vault/features/bottomNavigationbar/presentation/widgets/add_button_widget.dart';
import 'package:ijs_vault/features/linked_users/presentation/screens/linked_users_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/my_vault_screen.dart';
import 'package:ijs_vault/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:ijs_vault/features/settings/presentation/screens/settings_screen.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

class HomeWithBottomNavScreen extends StatefulWidget {
  const HomeWithBottomNavScreen({super.key});

  @override
  State<HomeWithBottomNavScreen> createState() =>
      _HomeWithBottomNavScreenState();
}

class _HomeWithBottomNavScreenState extends State<HomeWithBottomNavScreen> {
  final MyVaultController controller = Get.find<MyVaultController>();

  @override
  void initState() {
    super.initState();
    // Only fetch if items are empty (first load)
    if (controller.items.isEmpty) {
      controller.getVaultItems();
    }
  }

  int currentIndex = 0;

  // Use late initialization to keep pages alive
  late final List<Widget> pages = const <Widget>[
    MyVaultScreen(),
    RemindersScreen(),
    LinkedUsersScreen(),
    SettingsScreen(),
  ];

  final List<BottomNavItem> navItems = <BottomNavItem>[
    BottomNavItem(
      selectedImage: AppImages.selected1,
      unselectedImage: AppImages.unselected1,
      label: 'Vault',
    ),
    BottomNavItem(
      selectedImage: AppImages.selected2,
      unselectedImage: AppImages.unselected2,
      label: 'Reminder',
    ),
    BottomNavItem(
      selectedImage: AppImages.selected3,
      unselectedImage: AppImages.unselected3,
      label: 'Users',
    ),
    BottomNavItem(
      selectedImage: AppImages.selected4,
      unselectedImage: AppImages.unselected4,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final MyVaultController vaultcontroller = Get.find<MyVaultController>();
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: <Widget>[
          // Main content with padding for bottom nav
          // Using IndexedStack to keep pages alive and prevent refetching
          Padding(
            padding: EdgeInsets.only(
              bottom: 65 + MediaQuery.of(context).padding.bottom,
            ),
            child: IndexedStack(
              index: currentIndex,
              children: pages,
            ),
          ),

          // Blur overlay when add button is tapped
          Obx(
            () => vaultcontroller.isAddButtonTapped.value
                ? Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        color: isDarkMode
                            ? Colors.black.withValues(alpha: 0.5)
                            : const Color(0xFF494b52).withValues(alpha: 0.35),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Add button (floating)
          if (currentIndex == 0)
            Positioned(
              bottom: 80 + MediaQuery.of(context).padding.bottom,
              right: 20,
              child: const AddButtonWidget(),
            ),

          // Bottom Navigation Bar - attached to bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ModernBottomNavBar(
              currentIndex: currentIndex,
              items: navItems,
              onTap: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),

          // Upload Progress Overlay
          const UploadProgressOverlay(),
        ],
      ),
    );
  }
}

/// Modern Bottom Navigation Bar - Attached to bottom with glassmorphism effect
class ModernBottomNavBar extends StatelessWidget {
  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

    return Container(
      decoration: BoxDecoration(
        // Gradient border at the top
        border: Border(
          top: BorderSide(
            color: AppColors.gradient[0].withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        // Background with subtle gradient
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? <Color>[
                  const Color(0xFF1A1A1A),
                  const Color(0xFF0D0D0D),
                ]
              : <Color>[
                  Colors.white,
                  const Color(0xFFFAF9F6),
                ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List<Widget>.generate(items.length, (int index) {
              final bool isSelected = currentIndex == index;
              final BottomNavItem item = items[index];

              return Expanded(
                child: _NavBarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                  isDarkMode: isDarkMode,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Individual navigation bar item with modern animations
class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.isDarkMode,
  });

  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Icon
            SvgPicture.asset(
              isSelected ? item.selectedImage : item.unselectedImage,
              height: 24,
              width: 24,
            ),
            const SizedBox(height: 6),
            // Label - always visible
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.gradient[0]
                    : (isDarkMode ? Colors.white60 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  BottomNavItem({
    required this.selectedImage,
    required this.unselectedImage,
    required this.label,
  });
  final String selectedImage;
  final String unselectedImage;
  final String label;
}
