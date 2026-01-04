import 'package:flutter/material.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';

class ItemPreviewScreen extends StatelessWidget {
  const ItemPreviewScreen({super.key, required this.item});
  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: CustomAppBar(text: item.name));
  }
}
