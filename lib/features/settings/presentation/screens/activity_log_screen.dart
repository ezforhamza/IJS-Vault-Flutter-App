import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/settings/presentation/widgets/activity_log_widget.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final List<String> reminderTypes = <String>[
    'All Actions',
    'Shared',
    'Unshared',
    'Edited',
    'Created',
    'Deleted'
        'Moved',
    'Uploaded',
    'PIN Changed',
    'Reminder Set',
  ];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      appBar: const CustomAppBar(text: 'Activity Log'),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),

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
                        // You can filter the reminders list here based on selection
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
                            ? const LinearGradient(colors: AppColors.gradient)
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
                                : (isDarkMode ? Colors.white : Colors.black),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            //
            Expanded(
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return ActivityLogWidget(isDarkMode: isDarkMode);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 20);
                },
                itemCount: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
