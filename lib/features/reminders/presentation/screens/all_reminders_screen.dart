import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/features/reminders/data/models/reminders_model.dart';
import 'package:ijs_vault/features/reminders/presentation/controllers/reminder_controller.dart';
import 'package:ijs_vault/features/reminders/presentation/widgets/reminder_widget.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/loader_widget.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/search_field.dart';

class AllRemindersScreen extends StatefulWidget {
  const AllRemindersScreen({super.key});

  @override
  State<AllRemindersScreen> createState() => _AllRemindersScreenState();
}

class _AllRemindersScreenState extends State<AllRemindersScreen> {
  final List<String> reminderTypes = <String>[
    'All',
    'Pending',
    'Overdue',
    'Completed',
    'Snoozed',
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Trigger fetch for seamless refresh
    final ReminderController controller = Get.find<ReminderController>();
    controller.getAllReminders(showLoader: false);
  }

  @override
  Widget build(BuildContext context) {
    final ReminderController controller = Get.find<ReminderController>();
    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.black : AppColors.white,
      appBar: const CustomAppBar(text: "All Reminders"),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                CustomSearchField(isDarkMode: isDarkMode),
                const SizedBox(height: 15),

                // --------------------------------------------------
                // REMINDER TYPE FILTER (UI ONLY – LOGIC LATER)
                // --------------------------------------------------
                SizedBox(
                  height: 35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: reminderTypes.length,
                    itemBuilder: (BuildContext context, int index) {
                      final bool isSelected = index == selectedIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1000),
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: AppColors.gradient,
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : isDarkMode
                                ? const Color(0xFF20222b)
                                : Colors.grey[300],
                          ),
                          child: Center(
                            child: Text(
                              reminderTypes[index],
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : (isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --------------------------------------------------
          // REMINDERS LIST (CONNECTED TO CONTROLLER)
          // --------------------------------------------------
          Expanded(
            child: Obx(() {
              if (controller.isFetchingReminders.value) {
                return const Center(child: LoaderWidget());
              }

              // Apply Filter Logic (Basic implementation)
              List<ReminderItemModel> displayedList =
                  List<ReminderItemModel>.from(controller.reminders);

              if (selectedIndex == 1) {
                // Pending
                displayedList = displayedList
                    .where(
                      (ReminderItemModel r) =>
                          r.status.toLowerCase() == 'pending',
                    )
                    .toList();
              } else if (selectedIndex == 3) {
                // Completed
                displayedList = displayedList
                    .where(
                      (ReminderItemModel r) =>
                          r.status.toLowerCase() == 'completed',
                    )
                    .toList();
              }
              // Add other filters as needed logic permits

              if (displayedList.isEmpty) {
                return Center(
                  child: Text(
                    'No reminders found',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: displayedList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ReminderItemModel reminder = displayedList[index];
                    return ReminderWidget(reminder: reminder);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
