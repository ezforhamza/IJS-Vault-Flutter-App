import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/linked_users/data/models/linked_user_model.dart';
import 'package:ijs_vault/features/linked_users/presentation/widgets/shared_with_linked_user_grid.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/search_field.dart';

class SharedVaultScreen extends StatelessWidget {
  const SharedVaultScreen({super.key, required this.user});
  final LinkedUserModel user;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      appBar: CustomAppBar(text: "${user.fullName}'s Vault"),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            CustomSearchField(isDarkMode: isDarkMode),
            const SizedBox(height: 15),
            Expanded(child: SharedWithLinkedUserGrid(user: user)),
          ],
        ),
      ),
    );
  }
}
