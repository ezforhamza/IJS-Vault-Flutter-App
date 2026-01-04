import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/vault_item.dart';
import 'package:shimmer/shimmer.dart';

class MyVault extends StatefulWidget {
  const MyVault({super.key});

  @override
  State<MyVault> createState() => _MyVaultState();
}

class _MyVaultState extends State<MyVault> {
  final MyVaultController controller = Get.find<MyVaultController>();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
                child: child,
              ),
            );
          },
          child: controller.isGettingVault.value
              ? const GridShimmer(keyy: 'Shimmer')
              : _buildGrid(textTheme, const ValueKey('grid')),
        ),
      ),
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                                   GRID                                     */
  /* -------------------------------------------------------------------------- */

  Widget _buildGrid(TextTheme textTheme, ValueKey key) {
    if (controller.items.isEmpty) {
      return _buildEmptyText(textTheme);
    }

    return GridView.builder(
      key: key,
      padding: const EdgeInsets.all(10),
      itemCount: controller.items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, int index) {
        final ItemModel item = controller.items[index];
        return VaultItem(item: item);
      },
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                               EMPTY STATE                                  */
  /* -------------------------------------------------------------------------- */

  Widget _buildEmptyText(TextTheme textTheme) {
    return Center(
      child: Text(
        'No Folder & File Yet\n'
        'Start by creating your first folder to\n'
        'organize your vault.',
        textAlign: TextAlign.center,
        style: textTheme.labelSmall,
      ),
    );
  }
}

class GridShimmer extends StatelessWidget {
  const GridShimmer({super.key, required this.keyy});

  final String keyy;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return GridView.builder(
      key: ValueKey(keyy),
      padding: const EdgeInsets.all(10),
      itemCount: 9, // shimmer placeholders
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDarkMode
              ? Colors.grey.shade700
              : Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
