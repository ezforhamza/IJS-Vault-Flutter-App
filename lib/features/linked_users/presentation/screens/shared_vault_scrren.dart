import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/search_field.dart';

class SharedVaultScrren extends StatelessWidget {
  const SharedVaultScrren({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      appBar: const CustomAppBar(text: "Shared Vault"),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            CustomSearchField(isDarkMode: isDarkMode),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
