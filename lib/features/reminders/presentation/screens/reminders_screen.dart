import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/controllers/profile_controller.dart';
import 'package:ijs_vault/features/reminders/data/models/reminders_model.dart';
import 'package:ijs_vault/features/reminders/presentation/controllers/reminder_controller.dart';
import 'package:ijs_vault/features/reminders/presentation/screens/all_reminders_screen.dart';
import 'package:ijs_vault/features/reminders/presentation/widgets/calender_widget.dart';
import 'package:ijs_vault/features/reminders/presentation/widgets/reminder_widget.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReminderController controller = Get.put(ReminderController());
    // Trigger fetch on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getAllReminders(showLoader: false);
    });

    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.black : AppColors.white,
      appBar: CustomProfileAppBar(
        textTheme: Theme.of(context).textTheme,
        isCentre: true,
        title: 'Reminders',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Search
              // CustomSearchField(isDarkMode: isDarkMode),
              const SizedBox(height: 10),

              // Calendar
              const CalendarWidget(),
              const SizedBox(height: 20),

              // Title ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Upcoming',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  GestureDetector(
                    // Navigate to "All Reminders" or similar
                    onTap: () {
                      Get.to(() => const AllRemindersScreen());
                    },
                    child: Text(
                      'View All',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // List of reminders (showing recent/upcoming)
              Obx(() {
                if (controller.isFetchingReminders.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.reminders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No reminders found',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ),
                  );
                }

                // Show top 5 or so
                final List<ReminderItemModel> displayList = controller.reminders
                    .take(5)
                    .toList();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayList.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final ReminderItemModel reminder = displayList[index];
                    return ReminderWidget(reminder: reminder);
                  },
                );
              }),
              Container(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomProfileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomProfileAppBar({
    super.key,
    required this.textTheme,
    this.title,
    required this.isCentre,
  });
  final String? title;
  final bool isCentre;

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    final bool isDarkMode = Get.isDarkMode;

    return Obx(
      () => AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: isCentre,

        // LEFT WIDGET
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
          child: ProfilePictureWidget(
            radius: 15,
            imageUrl: controller.currentUser.value!.image,
          ),
        ),

        // TITLE
        title: Text(
          // ' ${controller.user.value!.fullName}',
          // controller.user.value == null ? "" : controller.user.value!.fullName,
          isCentre ? 'Reminders' : controller.userFullName!,
          style: textTheme.labelLarge!.copyWith(fontSize: 16),
        ),

        // RIGHT ACTION
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SvgPicture.asset(
              AppImages.bell,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Required for AppBar height
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
