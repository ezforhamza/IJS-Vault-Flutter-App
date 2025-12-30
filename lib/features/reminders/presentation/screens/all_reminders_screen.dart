import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/reminders/presentation/widgets/reminder_widget.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
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
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

    return Scaffold(
      appBar: const CustomAppBar(text: "Upcoming Reminders"),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            CustomSearchField(isDarkMode: isDarkMode),
            const SizedBox(height: 15),

            // Horizontal Reminder Type List
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

            // Reminders List
            Expanded(
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 10),
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) =>
                    const ReminderWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
