import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/bottomNavigationbar/presentation/widgets/add_button_widget.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/my_vault_screen.dart';
import 'package:ijs_vault/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/gradient_text_widget.dart';

class HomeWithBottomNavScreen extends StatefulWidget {
  const HomeWithBottomNavScreen({super.key});

  @override
  State<HomeWithBottomNavScreen> createState() =>
      _HomeWithBottomNavScreenState();
}

class _HomeWithBottomNavScreenState extends State<HomeWithBottomNavScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const <Widget>[
    MyVaultScreen(),
    RemindersScreen(),
    Center(child: Text('Profile Screen')),
    Center(child: Text('Setting Screen')),
  ];

  final List<BottomNavItem> navItems = <BottomNavItem>[
    BottomNavItem(
      selectedImage: AppImages.selected1,
      unselectedImage: AppImages.unselected1,
      label: 'My Vault',
    ),
    BottomNavItem(
      selectedImage: AppImages.selected2,
      unselectedImage: AppImages.unselected2,
      label: 'Reminders',
    ),
    BottomNavItem(
      selectedImage: AppImages.selected3,
      unselectedImage: AppImages.unselected3,
      label: 'Linked Users',
    ),
    BottomNavItem(
      selectedImage: AppImages.selected4,
      unselectedImage: AppImages.unselected4,
      label: 'Settings',
    ),
  ];
  bool isAddButtonTapped = false;
  @override
  Widget build(BuildContext context) {
    final MyVaultController vaultcontroller = Get.find<MyVaultController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,

      // floatingActionButton: currentIndex == 0
      //     ?
      //     : null,
      body: Stack(
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: pages[currentIndex],
          ),
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: CustomBottomNavBar(
              currentIndex: currentIndex,
              items: navItems,
              onTap: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),
          // if (isAddButtonTapped)
          Obx(
            () => vaultcontroller.isAddButtonTapped.value
                ? Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: Container(
                        color: const Color(0xFF494b52).withOpacity(0.35),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          if (currentIndex == 0)
            Positioned(
              bottom: 100 + MediaQuery.of(context).padding.bottom,
              right: 20,
              child: const AddButtonWidget(),
            ),
        ],
      ),
      // bottomNavigationBar:
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
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

    return SafeArea(
      child: Container(
        height: 70,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: const GradientBoxBorder(
            gradient: LinearGradient(colors: AppColors.gradient),
            width: 0.5,
          ),
          color: isDarkMode ? const Color(0xFF2a2514) : const Color(0xFFede6cd),
        ),
        child: Row(
          children: List.generate(items.length, (int index) {
            final bool isSelected = currentIndex == index;
            final BottomNavItem item = items[index];

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => onTap(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AnimatedScale(
                      scale: isSelected ? 1.25 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: SvgPicture.asset(
                        isSelected ? item.selectedImage : item.unselectedImage,
                        height: 24,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: -1,
                                child: child,
                              ),
                            );
                          },
                      child: isSelected
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: TextGradient(
                                key: ValueKey(item.label),
                                text: item.label,
                                fontsize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          }),
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
