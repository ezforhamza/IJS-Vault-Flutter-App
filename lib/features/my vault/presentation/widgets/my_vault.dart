import 'package:flutter/material.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/vault_item.dart';

class MyVault extends StatelessWidget {
  const MyVault({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: _buildGrid()),
          const SizedBox(height: 20),
          // _buildEmptyText(textTheme),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // ✅ 3 items per row
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (BuildContext context, int index) {
        return const VaultItem();
      },
    );
  }

  Widget _buildEmptyText(TextTheme textTheme) {
    return Text(
      'No Folder & File Yet\n'
      'Start by creating your first folder to\n'
      'organize your vault.',
      textAlign: TextAlign.center,
      style: textTheme.labelSmall,
    );
  }
}
