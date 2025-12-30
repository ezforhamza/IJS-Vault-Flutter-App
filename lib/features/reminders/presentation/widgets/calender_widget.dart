import 'package:flutter/material.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime selectedMonth = DateTime(2025, 8);
  DateTime today = DateTime.now();

  // Example reminders - add your dates here
  final List<DateTime> reminders = <DateTime>[
    DateTime(2025, 8, 14), // Past reminder (red)
    DateTime(2025, 8, 31), // Upcoming reminder (blue)
  ];

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

  bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool hasReminder(DateTime? date) {
    if (date == null) return false;
    return reminders.any((DateTime reminder) => isSameDay(reminder, date));
  }

  bool isReminderPassed(DateTime? date) {
    if (date == null) return false;
    final DateTime reminder = reminders.firstWhere(
      (DateTime r) => isSameDay(r, date),
      orElse: () => DateTime.now(),
    );
    return reminder.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime?> calendarDays = getCalendarDays();
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

    return Container(
      // height: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF201c15) : const Color(0xFFf6f1e1),
        borderRadius: const BorderRadius.all(Radius.circular(35)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: <Widget>[
            // Header with month and year selectors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Month selector
                Expanded(
                  child: Row(
                    mainAxisAlignment: .center,
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
                        dropdownColor: const Color(0xFF201c15),
                        underline: const SizedBox(),
                        alignment: AlignmentDirectional.center,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          // fontSize: 20,
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
                        dropdownColor: const Color(0xFF201c15),
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black, // fontSize: 20,
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
            GridView.builder(
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
                final bool isCurrentMonth = date?.month == selectedMonth.month;
                final bool isReminder = hasReminder(date);
                final bool isPassed = isReminderPassed(date);

                return isReminder
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isReminder
                              ? (isPassed
                                    ? const Color(0xFFE85D5D)
                                    : const Color(0xFF3B9FE8))
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            date?.day.toString() ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            date?.day.toString() ?? '',
                            style: TextStyle(
                              color: isCurrentMonth
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
            ),
          ],
        ),
      ),
    );
  }
}
