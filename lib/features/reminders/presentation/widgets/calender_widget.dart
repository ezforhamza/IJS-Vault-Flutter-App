import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/features/reminders/data/models/reminders_model.dart';
import 'package:ijs_vault/features/reminders/presentation/controllers/reminder_controller.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime selectedMonth;
  DateTime today = DateTime.now();
  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime(today.year, today.month);
  }

  List<String> monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  void changeMonth(int delta) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + delta);
    });
  }

  void changeYear(int delta) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year + delta, selectedMonth.month);
    });
  }

  List<DateTime?> getCalendarDays() {
    final DateTime firstDayOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      1,
    );
    final DateTime lastDayOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
    );
    final int firstWeekday = firstDayOfMonth.weekday % 7;

    final List<DateTime?> days = <DateTime?>[];

    // Add previous month's trailing days
    for (int i = firstWeekday - 1; i >= 0; i--) {
      days.add(DateTime(selectedMonth.year, selectedMonth.month, -i));
    }

    // Add current month's days
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      days.add(DateTime(selectedMonth.year, selectedMonth.month, i));
    }

    // Add next month's leading days to complete the grid
    final int remainingDays = 42 - days.length;
    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(selectedMonth.year, selectedMonth.month + 1, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime?> calendarDays = getCalendarDays();
    final bool isDarkMode = Get.isDarkMode;

    return Container(
      // height: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF201c15) : const Color(0xFFf6f1e1),
        borderRadius: const BorderRadius.all(Radius.circular(35)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Header with month and year selectors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Month selector
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          changeMonth(-1);
                        },
                        child: Icon(
                          Icons.chevron_left,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      // const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: selectedMonth.month,
                        dropdownColor: isDarkMode ? const Color(0xFF201c15) : Colors.white,
                        underline: const SizedBox(),
                        alignment: AlignmentDirectional.center,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        items: List.generate(12, (int index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text(monthNames[index]),
                          );
                        }),
                        onChanged: (int? value) {
                          if (value != null) {
                            setState(() {
                              selectedMonth = DateTime(
                                selectedMonth.year,
                                value,
                              );
                            });
                          }
                        },
                      ),
                      // const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          changeMonth(1);
                        },
                        child: Icon(
                          Icons.chevron_right,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Year selector
                Expanded(
                  child: Row(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          changeYear(-1);
                        },
                        child: Icon(
                          Icons.chevron_left,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),

                      // const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: selectedMonth.year,
                        dropdownColor: isDarkMode ? const Color(0xFF201c15) : Colors.white,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        items: List.generate(10, (int index) {
                          final int year = DateTime.now().year - 5 + index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (int? value) {
                          if (value != null) {
                            setState(() {
                              selectedMonth = DateTime(
                                value,
                                selectedMonth.month,
                              );
                            });
                          }
                        },
                      ),
                      // const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          changeYear(1);
                        },
                        child: Icon(
                          Icons.chevron_right,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Weekday headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((
                  String day,
                ) {
                  return SizedBox(
                    // width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Calendar grid
            // Calendar grid
            Obx(() {
              final ReminderController controller =
                  Get.find<ReminderController>();
              // Force rebuild when reminders change
              // ignore: unused_local_variable
              final int _ = controller.reminders.length;

              return GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(0),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 20,
                ),
                itemCount: calendarDays.length,
                itemBuilder: (BuildContext context, int index) {
                  final DateTime? date = calendarDays[index];
                  final bool isCurrentMonth =
                      date?.month == selectedMonth.month;

                  // Get Status Color
                  final Color? statusColor = _getDayStatusColor(
                    date,
                    controller,
                  );
                  final bool hasStatus = statusColor != null;

                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor ?? Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        date?.day.toString() ?? '',
                        style: TextStyle(
                          color: hasStatus
                              ? Colors.white
                              : isCurrentMonth
                              ? isDarkMode
                                    ? Colors.white
                                    : Colors.black
                              : const Color(0xFF888888),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Color? _getDayStatusColor(DateTime? date, ReminderController controller) {
    if (date == null) return null;

    final List<ReminderItemModel> dayReminders = controller.reminders.where((
      ReminderItemModel r,
    ) {
      if (r.date.isEmpty) return false;
      try {
        final DateTime rDate = DateTime.parse(r.date);
        return rDate.year == date.year &&
            rDate.month == date.month &&
            rDate.day == date.day;
      } catch (e) {
        return false;
      }
    }).toList();

    if (dayReminders.isEmpty) return null;

    // Check Priority: Overdue > Pending > Snoozed > Completed
    bool hasOverdue = false;
    bool hasPending = false;
    bool hasSnoozed = false;
    bool hasCompleted = false;

    final DateTime now = DateTime.now();
    final DateTime todayStart = DateTime(now.year, now.month, now.day);

    for (final ReminderItemModel r in dayReminders) {
      final String status = r.status.toLowerCase();

      // Overdue check: Pending and date is strictly before today
      // (Ignoring time for calendar dot simplicity, strictly date based)
      if (status == 'pending' && date.isBefore(todayStart)) {
        hasOverdue = true;
      } else if (status == 'pending') {
        hasPending = true;
      } else if (status == 'snoozed') {
        hasSnoozed = true;
      } else if (status == 'completed') {
        hasCompleted = true;
      }
    }

    if (hasOverdue) return const Color(0xFFE85D5D); // Red
    if (hasPending) return const Color(0xFF3B9FE8); // Blue
    if (hasSnoozed) return Colors.orangeAccent;
    if (hasCompleted) return Colors.green; // Green

    return null;
  }
}
