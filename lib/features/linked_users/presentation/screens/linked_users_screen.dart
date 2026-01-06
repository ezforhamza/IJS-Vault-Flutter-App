import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/linked_users/data/models/linked_user_model.dart';
import 'package:ijs_vault/features/linked_users/presentation/controllers/linked_users_controller.dart';
import 'package:ijs_vault/features/linked_users/presentation/screens/all_linked_users_screen.dart';
import 'package:ijs_vault/features/linked_users/presentation/widgets/linked_user_widget.dart';
import 'package:ijs_vault/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:ijs_vault/shared/widgets/search_field.dart';

class LinkedUsersScreen extends StatefulWidget {
  const LinkedUsersScreen({super.key});

  @override
  State<LinkedUsersScreen> createState() => _LinkedUsersScreenState();
}

class _LinkedUsersScreenState extends State<LinkedUsersScreen> {
  final LinkedUsersController controller = Get.find<LinkedUsersController>();

  @override
  void initState() {
    super.initState();
    controller.getLinkedUsers(showLoader: false);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;

    return SafeArea(
      child: Scaffold(
        appBar: CustomProfileAppBar(
          textTheme: textTheme,
          isCentre: true,
          title: 'Linked Users',
        ),
        body: Padding(
          padding: AppSizes.horizontalPadding,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              CustomSearchField(isDarkMode: isDarkMode),
              const SizedBox(height: 20),

              Row(
                children: <Widget>[
                  Text(
                    'Linked Users',
                    style: textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const AllLinkedUsersScreen());
                    },
                    child: Text(
                      'View All',
                      style: textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// 👇 Controller-driven UI
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.users.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.users.isEmpty) {
                    return Center(child: buildEmptyText(textTheme));
                  }

                  return ListView.separated(
                    itemCount: controller.users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final LinkedUserModel user = controller.users[index];
                      return LinkedUserWidget(
                        // pass model here
                        user: user,
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Text buildEmptyText(TextTheme textTheme) {
    return Text(
      textAlign: TextAlign.center,
      'No linked users yet.\nInvite people you trust to safely access your vault.',
      style: textTheme.labelSmall,
    );
  }
}
