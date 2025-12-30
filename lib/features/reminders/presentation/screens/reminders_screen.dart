import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/reminders/presentation/screens/all_reminders_screen.dart';
import 'package:ijs_vault/features/reminders/presentation/widgets/calender_widget.dart';
import 'package:ijs_vault/features/reminders/presentation/widgets/reminder_widget.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';
import 'package:ijs_vault/shared/widgets/search_field.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = ScreenHelper.isdarkMode(context);
    return SafeArea(
      child: Scaffold(
        appBar: ReminderProfileHeader(textTheme: textTheme),
        body: Padding(
          padding: AppSizes.horizontalPadding,
          child: Column(
            spacing: 10,
            children: <Widget>[
              // _buildSearchField(isDarkMode)
              //
              CustomSearchField(isDarkMode: isDarkMode),

              // Calender
              const CalendarWidget(),
              // Upcoming Reminders
              Row(
                children: <Widget>[
                  Text(
                    'Upcoming Reminders',
                    style: textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const AllRemindersScreen());
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
              // Rminders
              buildUpComingRemindersList(textTheme),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUpComingRemindersList(TextTheme textTheme) {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 10);
        },
        padding: const EdgeInsets.all(0),
        // shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return const ReminderWidget();
        },
      ),
    );
  }
}

class ReminderProfileHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const ReminderProfileHeader({super.key, required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,

      // LEFT WIDGET
      leading: const Padding(
        padding: EdgeInsets.only(left: 12, top: 12, bottom: 12),
        child: ProfilePictureWidget(
          radius: 15,
          imageUrl: "https://randomuser.me/api/portraits/men/1.jpg",
        ),
      ),

      // TITLE
      title: Text(
        'Reminders',
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
    );
  }

  /// Required for AppBar height
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
