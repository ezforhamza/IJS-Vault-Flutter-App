import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/linked_users/data/models/linked_user_model.dart';
import 'package:ijs_vault/features/linked_users/presentation/controllers/linked_users_controller.dart';
import 'package:ijs_vault/features/linked_users/presentation/widgets/linked_user_widget.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/search_field.dart';
import 'package:shimmer/shimmer.dart';

class AllLinkedUsersScreen extends StatelessWidget {
  const AllLinkedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LinkedUsersController controller = Get.find<LinkedUsersController>();
    final bool isDarkMode = Get.isDarkMode;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CustomAppBar(text: "Linked Users"),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            CustomSearchField(isDarkMode: isDarkMode),
            const SizedBox(height: 20),

            /// Controller-driven list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _LinkedUsersShimmer(isDarkMode: isDarkMode);
                }

                if (controller.users.isEmpty) {
                  return _buildEmptyState(isDarkMode, textTheme);
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  color: AppColors.gradient[0],
                  child: ListView.separated(
                    itemCount: controller.users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final LinkedUserModel user = controller.users[index];
                      return LinkedUserWidget(user: user);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: isDarkMode ? Colors.white38 : Colors.black26,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Linked Users',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share files or folders with others\nto see them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedUsersShimmer extends StatelessWidget {
  const _LinkedUsersShimmer({required this.isDarkMode});
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor:
              isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF20222b) : Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(
                color: isDarkMode ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Row(
              children: <Widget>[
                // Avatar shimmer
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // Content shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 180,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Container(
                            height: 10,
                            width: 60,
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 10,
                            width: 50,
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Role badge shimmer
                Container(
                  height: 24,
                  width: 50,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
