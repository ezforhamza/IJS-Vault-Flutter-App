import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitThreeBounce(
        size: 28,
        itemBuilder: (BuildContext context, int index) {
          return const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: AppColors.gradient),
            ),
          );
        },
      ),
    );
  }
}
