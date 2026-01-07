import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';

class MoveItemDialog extends StatefulWidget {
  const MoveItemDialog({
    super.key,
    required this.itemToMove,
    this.initialParentId,
    required this.onMove,
  });

  final ItemModel itemToMove;
  final String? initialParentId;
  final Function(String? newParentId) onMove;

  @override
  State<MoveItemDialog> createState() => _MoveItemDialogState();
}

class _MoveItemDialogState extends State<MoveItemDialog> {
  final MyVaultRepo _repo = MyVaultRepo();

  // Navigation State
  String? _currentParentId; // null = root
  String _currentFolderName = 'Select Folder';
  final List<Map<String, dynamic>> _history =
      <Map<String, dynamic>>[]; // Stack of {id, name}

  // Data State
  bool _isLoading = false;
  List<ItemModel> _folders = <ItemModel>[];

  @override
  void initState() {
    super.initState();
    // Start at root by default
    _currentParentId = null;
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    setState(() => _isLoading = true);
    try {
      final ApiResponse response = await _repo.getVaultItems(
        parentId: _currentParentId,
      );
      if (response.success) {
        final ItemsResponseModel data = ItemsResponseModel.fromJson(
          response.data,
        );
        // Filter only folders and exclude the item itself (cannot move inside itself)
        final List<ItemModel> allItems = data.items;
        setState(() {
          _folders = allItems.where((ItemModel item) {
            return item.type == 'folder' && item.id != widget.itemToMove.id;
          }).toList();
        });
      } else {
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      debugPrint('Error loading folders: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _enterFolder(ItemModel folder) {
    // Push current state to history
    _history.add(<String, dynamic>{
      'id': _currentParentId,
      'name': _currentFolderName,
    });

    // Update state
    setState(() {
      _currentParentId = folder.id;
      _currentFolderName = folder.name;
    });

    _loadFolders();
  }

  void _goBack() {
    if (_history.isEmpty) return;

    final Map<String, dynamic> previous = _history.removeLast();
    setState(() {
      _currentParentId = previous['id'];
      _currentFolderName = previous['name'];
    });

    _loadFolders();
  }

  void _handleMove() {
    // Check if we are trying to move to the same location
    if (_currentParentId == widget.itemToMove.parentId) {
      AppToasts.showErrorToast(message: "Item is already in this folder.");
      return;
    }

    widget.onMove(_currentParentId);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 300,
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(),
                Expanded(
                  child: Center(
                    child: Text(
                      _currentFolderName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // if (_history.isNotEmpty)
                // IconButton(
                //   icon: Icon(
                //     Icons.close,
                //     color: isDarkMode ? Colors.white : Colors.black,
                //   ),
                //   onPressed: _goBack,
                // ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _folders.isEmpty
                  ? Center(
                      child: Text(
                        "No sub-folders",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadius,
                        ),
                        color: isDarkMode
                            ? const Color(0xFF272214)
                            : const Color(0xFFf4edd7),
                        border: const GradientBoxBorder(
                          gradient: LinearGradient(colors: AppColors.gradient),
                        ),
                      ),
                      child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 20);
                        },
                        shrinkWrap: true,
                        itemCount: _folders.length,
                        itemBuilder: (BuildContext context, int index) {
                          final ItemModel folder = _folders[index];

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _enterFolder(folder),
                            child: Row(
                              spacing: 5,
                              children: <Widget>[
                                SvgPicture.asset(AppImages.folder),
                                Text(
                                  folder.name,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.chevron_right,
                                  color: isDarkMode
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ],
                            ),
                          );
                          // return ListTile(
                          //   leading: Icon(
                          //     Icons.folder,
                          //     color: isDarkMode ? Colors.amber : Colors.amber,
                          //   ),
                          //   title: Text(
                          //     folder.name,
                          //     style: TextStyle(
                          //       color: isDarkMode ? Colors.white : Colors.black,
                          //     ),
                          //   ),
                          //   trailing: Icon(
                          //     Icons.chevron_right,
                          //     color: isDarkMode
                          //         ? Colors.white54
                          //         : Colors.black54,
                          //   ),
                          //   onTap: () => _enterFolder(folder),
                          // );
                        },
                      ),
                    ),
            ),

            const SizedBox(height: 10),

            // Action Button
            // ElevatedButton(
            //   onPressed: _handleMove,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: AppColors.gradient[0],
            //     padding: const EdgeInsets.symmetric(vertical: 12),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            //   child: const Text(
            //     "Move Here",
            //     style: TextStyle(color: Colors.white, fontSize: 16),
            //   ),
            // ),
            if (_history.isNotEmpty)
              CustomButton(
                onTap: () {
                  _handleMove();
                },
                text: 'Move',
              ),
          ],
        ),
      ),
    );
  }
}
