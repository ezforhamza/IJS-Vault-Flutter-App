import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

class PfpSelectionWidget extends StatelessWidget {
  const PfpSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ScreenHelper.isdarkMode(context);

    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        children: [
          Center(
            child: ClipOval(
              child: Container(
                height: 100,
                width: 100,

                decoration: BoxDecoration(
                  color: isDarkMode ? Color(0xFF34353d) : Color(0xFFf7f7f7),
                ),
              ),
            ),
          ),
          Center(
            child: SvgPicture.asset(
              AppImages.pfpicon2,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),

          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              clipBehavior: Clip.hardEdge,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
                color: Color(0xFFdbdbdb),
                border: Border.all(
                  color: isDarkMode ? Colors.black : Colors.white,
                  width: 3,
                ),
              ),
              child: SvgPicture.asset(AppImages.pfpicon1),
            ),
          ),
        ],
      ),
    );
  }
}
