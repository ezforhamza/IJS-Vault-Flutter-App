import 'package:flutter/material.dart';

class DialogHelper {
  static void showAnimatedDialog({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    String barrierLabel = 'Dialog',
    Duration transitionDuration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutBack,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: transitionDuration,
      pageBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return Center(child: child);
          },
      transitionBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final CurvedAnimation curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: curvedAnimation, child: child),
            );
          },
    );
  }
}
