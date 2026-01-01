import 'package:flutter/material.dart';

class KeyboardHelper {
  /// Closes the keyboard if it is currently open
  static void closeKeyboard(BuildContext context) {
    final FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
  }
}
