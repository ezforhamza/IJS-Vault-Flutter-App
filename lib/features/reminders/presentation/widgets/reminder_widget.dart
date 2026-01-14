import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/domain/repositories/my_vault_repo.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/folder_view_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/item_preview_screen.dart';
import 'package:ijs_vault/features/reminders/data/models/reminders_model.dart';
import 'package:ijs_vault/features/reminders/presentation/controllers/reminder_controller.dart';
import 'package:ijs_vault/features/set%20pin/presentation/screens/verify_pin_screen.dart';
import 'package:ijs_vault/shared/helpers/loader.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';
import 'package:ijs_vault/shared/models/response_model.dart';

class ReminderWidget extends StatefulWidget {
  const ReminderWidget({super.key, required this.reminder});

  final ReminderItemModel reminder;

  @override
  State<ReminderWidget> createState() => _ReminderWidgetState();
}

class _ReminderWidgetState extends State<ReminderWidget> {
  final GlobalKey _moreKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;
  bool _isDisposed = false;
  final MyVaultRepo _repo = MyVaultRepo();

  // -------------------------------
  // Lifecycle
  // -------------------------------

  @override
  void didChangeDependencies() {
    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      _removeOverlay();
      return true;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _removeOverlay(fromDispose: true);
    super.dispose();
  }

  // -------------------------------
  // Overlay control
  // -------------------------------

  void _toggleMenu() {
    if (_isMenuOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    if (_isDisposed || _overlayEntry != null) return;

    final RenderBox renderBox =
        _moreKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        final bool isDarkMode = Get.isDarkMode;

        return Stack(
          children: <Widget>[
            /// Tap outside
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => _removeOverlay(),
                child: const SizedBox.expand(),
              ),
            ),

            /// Dropdown
            Positioned(
              left: offset.dx - 120,
              top: offset.dy + size.height + 6,
              width: 140,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.white,
                    // borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (widget.reminder.status != 'completed')
                        _buildMenuItem(
                          title: 'Mark Complete',
                          image: AppImages.markcomplete,
                          isdel: false,
                          onTap: () {
                            Get.find<ReminderController>().markAsComplete(
                              widget.reminder.id,
                            );
                          },
                        ),
                      if (widget.reminder.status == 'completed')
                        _buildMenuItem(
                          title: 'Mark Pending',
                          image: AppImages.bell2,
                          isdel: false,
                          onTap: () {
                            Get.find<ReminderController>().markAsPending(
                              widget.reminder.id,
                            );
                          },
                        ),
                      const Divider(),
                      _buildMenuItem(
                        title: 'Delete',
                        image: AppImages.delete,
                        isdel: true,
                        onTap: () {
                          Get.find<ReminderController>().deleteReminder(
                            widget.reminder.id,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    if (mounted) {
      setState(() => _isMenuOpen = true);
    }
  }

  void _removeOverlay({bool fromDispose = false}) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (fromDispose || !mounted || _isDisposed) return;

    if (_isMenuOpen) {
      setState(() => _isMenuOpen = false);
    }
  }

  // -------------------------------
  // Menu Item
  // -------------------------------

  Widget _buildMenuItem({
    required String title,
    required String image,
    required bool isdel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        _removeOverlay();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(
              image,
              color: isdel
                  ? null
                  : ScreenHelper.isdarkMode(context)
                  ? Colors.white
                  : Colors.black,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: ScreenHelper.isdarkMode(context)
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // UI
  // -------------------------------

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;

    // Check status
    final bool isCompleted = widget.reminder.status == 'completed';
    // Simple improved check for overdue: if pending & past due
    // Note: Ideally compare parsed date/time
    bool isOverdue = false;
    try {
      final String dateTimeStr =
          "${widget.reminder.date} ${widget.reminder.time}";
      final DateTime dt = DateTime.parse(dateTimeStr);
      if (dt.isBefore(DateTime.now()) && !isCompleted) {
        isOverdue = true;
      }
    } catch (e) {
      // ignore
    }

    // Border color based on status
    Color borderColor = isDarkMode
        ? const Color(0xFF47443b)
        : const Color(0xFFf7f2e0);
    if (isOverdue) borderColor = Colors.redAccent.withOpacity(0.5);
    if (isCompleted) borderColor = Colors.green.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF20222b) : Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Title
              Expanded(
                child: Text(
                  widget.reminder.title,
                  style: textTheme.labelMedium!.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // const Spacer(),
              InkWell(
                key: _moreKey,
                onTap: _toggleMenu,
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Associated Item Info - Tappable to show options
          GestureDetector(
            onTap: () => _showFileOptionsBottomSheet(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: <Widget>[
                  // Icon based on type (simple logic for now)
                  SvgPicture.asset(
                    _getIconForType(widget.reminder.itemType),
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.reminder.itemName,
                          style: textTheme.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.reminder.itemType.toUpperCase(),
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isDarkMode ? Colors.white38 : Colors.black38,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Description
          if (widget.reminder.description.isNotEmpty) ...<Widget>[
            Text(
              widget.reminder.description,
              style: textTheme.labelSmall!.copyWith(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],

          // DateTime
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: 'Reminder Date & Time: ',
                  style: textTheme.labelMedium,
                ),
                TextSpan(
                  text: '${widget.reminder.date} - ${widget.reminder.time}',
                  style: textTheme.labelSmall!.copyWith(
                    fontSize: 14,
                    color: isOverdue ? Colors.redAccent : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getIconForType(String type) {
    if (type.contains('pdf')) return AppImages.pdf;
    if (type.contains('doc')) return AppImages.doc;
    if (type.contains('image')) return AppImages.image;
    // fallback
    return AppImages.pdf;
  }

  // -------------------------------
  // File Options Bottom Sheet
  // -------------------------------

  void _showFileOptionsBottomSheet() {
    final bool isDarkMode = Get.isDarkMode;
    final String itemId = widget.reminder.itemId.id;
    final String itemType = widget.reminder.itemId.type;

    // For folders, navigate directly
    if (itemType == 'folder') {
      _openItem(itemId, 'folder');
      return;
    }

    // For files, show options bottom sheet
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'What would you like to do?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.folder_open,
              title: 'View in Folder',
              subtitle: 'Navigate to the folder containing this file',
              isDarkMode: isDarkMode,
              onTap: () {
                Get.back();
                _navigateToParentFolder(itemId);
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              icon: Icons.visibility,
              title: 'Preview File',
              subtitle: 'Open file preview and download options',
              isDarkMode: isDarkMode,
              onTap: () {
                Get.back();
                _openItem(itemId, 'file');
              },
            ),
            SizedBox(height: MediaQuery.of(Get.context!).padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2a2a2a) : const Color(0xFFf5f5f5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.gradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToParentFolder(String itemId) async {
    AppLoader.showLoadingDialog();

    try {
      final ApiResponse response = await _repo.getItemById(itemId: itemId);

      if (response.success) {
        final ItemModel item = ItemModel.fromJson(
          response.data['item'] ?? response.data,
        );
        AppLoader.hideLoadingDialog();

        // Get the parent folder ID from the item
        final String? parentId = item.parentId?.toString();

        if (parentId != null && parentId.isNotEmpty && parentId != 'null') {
          // Fetch the parent folder details
          final ApiResponse parentResponse = await _repo.getItemById(
            itemId: parentId,
          );

          if (parentResponse.success) {
            final ItemModel parentFolder = ItemModel.fromJson(
              parentResponse.data['item'] ?? parentResponse.data,
            );

            if (parentFolder.isLocked) {
              Get.to(
                () => VerifyPinScreen(
                  itemId: parentFolder.id,
                  onSuccess: () {
                    Get.off(() => FolderViewScreen(item: parentFolder));
                  },
                ),
              );
            } else {
              Get.to(() => FolderViewScreen(item: parentFolder));
            }
          } else {
            AppToasts.showErrorToast(message: 'Failed to load parent folder');
          }
        } else {
          // File is in root
          AppToasts.showSuccessToast(message: 'File is in root folder');
        }
      } else {
        AppLoader.hideLoadingDialog();
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      AppLoader.hideLoadingDialog();
      debugPrint('Error navigating to parent folder: $e');
      AppToasts.showErrorToast(message: 'Failed to load folder');
    }
  }

  Future<void> _openItem(String itemId, String type) async {
    AppLoader.showLoadingDialog();

    try {
      final ApiResponse response = await _repo.getItemById(itemId: itemId);

      if (response.success) {
        final ItemModel item = ItemModel.fromJson(
          response.data['item'] ?? response.data,
        );
        AppLoader.hideLoadingDialog();

        if (item.isLocked) {
          Get.to(
            () => VerifyPinScreen(
              itemId: item.id,
              onSuccess: () {
                if (type == 'folder') {
                  Get.off(() => FolderViewScreen(item: item));
                } else {
                  Get.off(() => ItemPreviewScreen(item: item));
                }
              },
            ),
          );
        } else {
          if (type == 'folder') {
            Get.to(() => FolderViewScreen(item: item));
          } else {
            Get.to(() => ItemPreviewScreen(item: item));
          }
        }
      } else {
        AppLoader.hideLoadingDialog();
        AppToasts.showErrorToast(message: response.message);
      }
    } catch (e) {
      AppLoader.hideLoadingDialog();
      debugPrint('Error opening item: $e');
      AppToasts.showErrorToast(message: 'Failed to load item');
    }
  }
}
