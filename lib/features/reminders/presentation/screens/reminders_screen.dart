import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/features/reminders/data/models/reminders_model.dart';
import 'package:ijs_vault/features/reminders/presentation/controllers/reminder_controller.dart';
import 'package:ijs_vault/features/reminders/presentation/screens/all_reminders_screen.dart';
import 'package:ijs_vault/features/reminders/presentation/widgets/calender_widget.dart';
import 'package:ijs_vault/features/reminders/presentation/widgets/reminder_widget.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReminderController controller = Get.put(ReminderController());
    // Trigger fetch on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getAllReminders();
    });

    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.black : AppColors.white,
      appBar: const CustomAppBar(text: 'Reminders'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
