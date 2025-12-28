import 'package:flutter/material.dart';

class MyVault extends StatelessWidget {
  const MyVault({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(body: Center(child: buildEmptyText(textTheme)));
  }

  Text buildEmptyText(TextTheme textTheme) {
    return Text(
      textAlign: .center,
      'No Folder & File\n YetStart by creating your first folder to \norganize your vault.',
      style: textTheme.labelSmall,
    );
  }
}
