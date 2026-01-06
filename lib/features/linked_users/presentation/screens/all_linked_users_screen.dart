import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/linked_users/data/models/linked_user_model.dart';
import 'package:ijs_vault/features/linked_users/presentation/controllers/linked_users_controller.dart';
import 'package:ijs_vault/features/linked_users/presentation/widgets/linked_user_widget.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/search_field.dart';

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

            /// 👇 Controller-driven list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.users.isEmpty) {
                  return Center(
                    child: Text(
                      'No linked users found.',
                      style: textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: controller.users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final LinkedUserModel user = controller.users[index];
                    return LinkedUserWidget(user: user);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
