import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/route_manager.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/linked_users/presentation/screens/all_linked_users_screen.dart';
import 'package:ijs_vault/features/linked_users/presentation/widgets/linked_user_widget.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';
import 'package:ijs_vault/shared/widgets/search_field.dart';

class LinkedUsersScreen extends StatelessWidget {
  const LinkedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = ScreenHelper.isdarkMode(context);
    return SafeArea(
      child: Scaffold(
        appBar: LinkedUsersProfileHeader(textTheme: textTheme),
        body: Padding(
          padding: AppSizes.horizontalPadding,
          child: Column(
            spacing: 20,
            children: <Widget>[
              // _buildSearchField(isDarkMode)
              //
              CustomSearchField(isDarkMode: isDarkMode),

              //
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

              _buildLinkedUsers(textTheme),

              // Rminders
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkedUsers(TextTheme theme) {
    return Expanded(
      // child: Container(child: Center(child: buildEmptyText(theme))),
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return const LinkedUserWidget();
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 10);
        },
        itemCount: 5,
      ),
    );
  }

  Text buildEmptyText(TextTheme textTheme) {
    return Text(
      textAlign: .center,
      'No linked users yet.\nInvite people you trust to safely access your vault.',
      style: textTheme.labelSmall,
    );
  }
}

class LinkedUsersProfileHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const LinkedUsersProfileHeader({super.key, required this.textTheme});

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
        'Linked Users',
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
