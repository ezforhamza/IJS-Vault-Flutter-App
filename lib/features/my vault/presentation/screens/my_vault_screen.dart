import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/shared/widgets/profile_picture_widget.dart';

class MyVaultScreen extends StatelessWidget {
  const MyVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: AppSizes.horizontalPadding,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              // Build Header
              ProfileHeader(textTheme: textTheme),

              // Search Bar
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  // prefixIcon: Image.asset(AppImages.search, height: 20),
                  // prefixIconConstraints: const BoxConstraints(
                  //   maxHeight: 20,
                  //   maxWidth: 20,
                  // ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    borderSide: const BorderSide(color: Colors.white),
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Image
        const ProfilePictureWidget(
          radius: 15,
          imageUrl: "https://randomuser.me/api/portraits/men/1.jpg",
        ),
        const SizedBox(width: 5),

        // Name
        Text(
          'Hello, John Marston',
          style: textTheme.labelLarge!.copyWith(fontSize: 16),
        ),
        const Spacer(),

        // Icon
        SvgPicture.asset(AppImages.bell),
      ],
    );
  }
}
