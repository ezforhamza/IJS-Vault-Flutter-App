import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/shared_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/my_vault_widget.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/shared_filter_sheet.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/shared_with_me.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/vault_filter_sheet.dart';
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
  int _currentTabIndex = 0;

  final List<String> tabs = <String>['Vault', 'Shared'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              // Search Bar with Filter Button
              _buildSearchWithFilter(isDarkMode),

              // Gradient TabBar
              _buildGradientTabBar(isDarkMode),

              // TabBar Views
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: const <Widget>[MyVault(), SharedWithMe()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchWithFilter(bool isDarkMode) {
    return Row(
      children: <Widget>[
        Expanded(child: CustomSearchField(isDarkMode: isDarkMode)),
        const SizedBox(width: 10),
        _buildFilterButton(isDarkMode),
      ],
    );
  }

  Widget _buildFilterButton(bool isDarkMode) {
    final MyVaultController vaultController = Get.find<MyVaultController>();

    if (_currentTabIndex == 0) {
      return Obx(() {
        final int filterCount = vaultController.activeFilterCount;
        final bool hasFilters = filterCount > 0;
        return _filterButtonWidget(isDarkMode, hasFilters, filterCount);
      });
    } else {
      return GetBuilder<SharedVaultController>(
        init: SharedVaultController(),
        builder: (SharedVaultController sharedController) {
          return Obx(() {
            final int filterCount = sharedController.activeFilterCount;
            final bool hasFilters = filterCount > 0;
            return _filterButtonWidget(isDarkMode, hasFilters, filterCount);
          });
        },
      );
    }
  }

  Widget _filterButtonWidget(bool isDarkMode, bool hasFilters, int filterCount) {
    return GestureDetector(
      onTap: () => _showFilterSheet(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: hasFilters
              ? const LinearGradient(colors: AppColors.gradient)
              : null,
          color: hasFilters
              ? null
              : (isDarkMode
                  ? const Color(0xFF494a51)
                  : const Color(0xFFf4f4f4)),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(
            color: hasFilters
                ? Colors.transparent
                : (isDarkMode ? Colors.white : const Color(0xFFb2b2b2)),
            width: 1.2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              Icons.tune_rounded,
              size: 22,
              color: hasFilters
                  ? Colors.white
                  : (isDarkMode ? Colors.white70 : Colors.black54),
            ),
            if (hasFilters)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      filterCount.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB98F04),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    Get.bottomSheet(
      _currentTabIndex == 0
          ? const VaultFilterSheet()
          : const SharedFilterSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
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
