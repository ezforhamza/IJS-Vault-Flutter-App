import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';

class AllNotificationsScreen extends StatelessWidget {
  const AllNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: const CustomAppBar(text: 'Notifications'),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: ListView.separated(
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 20);
          },
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              crossAxisAlignment: .start,
              spacing: 10,
              children: <Widget>[
                // Text
                Expanded(
                  child: Text(
                    'THis is the body of naotification hdh dhdd hdd dhdh dhd dh dhd ddhdh d dhddhdh dhd d',
                    style: theme.labelSmall,
                  ),
                ),
                // TIme
                Text('5m ago', style: theme.labelSmall),
              ],
            );
          },
        ),
      ),
    );
  }
}
