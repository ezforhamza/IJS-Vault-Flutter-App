import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: const CustomAppBar(text: 'Terms & Conditions'),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            Text(
              'Lorem ipsum dolor sit amet consectetur. Pharetra et felis nulla pellentesque tristique sed. Orci neque lorem rutrum pellentesque facilisis pulvinar in. Tortor ut a rhoncus arcu mauris. Nisl tortor mattis eget scelerisque. Ut leo sit ultrices eu dictum purus fames lorem sagittis. Ultricies integer curabitur tristique auctor. Felis potenti massa vitae adipiscing ultrices consequat quis mattis viverra. Et amet non diam commodo tristique commodo. Nisl massa maecenas mauris neque. Scelerisque gravida tincidunt habitant senectus quisque maecenas volutpat. Non elementum placerat magna sed pharetra aliquet risus imperdiet neque. At sagittis nunc diam dignissim. Pretium in ornare aenean felis consectetur feugiat eu dolor. At quis lacus pharetra sem.',

              style: textTheme.labelSmall!.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
