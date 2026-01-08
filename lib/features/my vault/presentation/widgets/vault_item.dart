import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/features/my%20vault/data/models/vault_item_model.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/folder_view_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/screens/item_preview_screen.dart';
import 'package:ijs_vault/features/my%20vault/presentation/widgets/set_reminder_widget.dart';
import 'package:ijs_vault/features/set%20pin/presentation/screens/verify_pin_screen.dart';
import 'package:ijs_vault/shared/helpers/dialog_helper.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

/// ---------------------------------------------------------------------------
/// ENUM
/// ---------------------------------------------------------------------------
enum VaultItemType { folder, media, document, secureNote }

/// ---------------------------------------------------------------------------
/// MENU ACTION MODEL
/// ---------------------------------------------------------------------------
class VaultMenuAction {
  const VaultMenuAction({
    required this.title,
    required this.icon,
    this.onTap,
    this.isDelete = false,
  });
  final String title;
  final String icon;
  final VoidCallback? onTap;
  final bool isDelete;
}

/// ---------------------------------------------------------------------------
/// WIDGET
/// ---------------------------------------------------------------------------
class VaultItem extends StatefulWidget {
  const VaultItem({
    super.key,
    required this.item,
    required this.type,
    this.onEdit,
    this.onMove,
    this.onDelete,
    this.onTap,
    this.isSharedItem = false,
  });

  final ItemModel item;
  final VaultItemType type;
  final VoidCallback? onEdit;
  final VoidCallback? onMove;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool isSharedItem;

  @override
  State<VaultItem> createState() => _VaultItemState();
}

class _VaultItemState extends State<VaultItem> {
  final GlobalKey _itemKey = GlobalKey();
  final GlobalKey _moreKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;
  bool _isDisposed = false;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // OVERLAY CONTROL
  // ---------------------------------------------------------------------------

  void _toggleMenu() {
    _isMenuOpen ? _removeOverlay() : _showOverlay();
  }

  void _showOverlay() {
    if (_isDisposed || _overlayEntry != null) return;

    final RenderBox iconBox =
        _moreKey.currentContext!.findRenderObject() as RenderBox;
    final Offset iconOffset = iconBox.localToGlobal(Offset.zero);
    final double iconHeight = iconBox.size.height;

    final RenderBox itemBox =
        _itemKey.currentContext!.findRenderObject() as RenderBox;
    final double itemLeft = itemBox.localToGlobal(Offset.zero).dx;

    final List<VaultMenuAction> actions = _getMenuActions();

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        final bool isDarkMode = Get.isDarkMode;

        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => _removeOverlay(),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: itemLeft,
              top: iconOffset.dy + iconHeight + 6,
              width: 110,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: actions.map((VaultMenuAction action) {
                      if (action.isDelete) {
                        return Column(
                          children: <Widget>[
                            const Divider(),
                            _menuItem(action),
                          ],
                        );
                      }
                      return _menuItem(action);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isMenuOpen = true);
  }

  void _removeOverlay({bool fromDispose = false}) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (fromDispose || !mounted || _isDisposed) return;
    setState(() => _isMenuOpen = false);
  }

  // ---------------------------------------------------------------------------
  // MENU CONFIGURATION
  // ---------------------------------------------------------------------------

  List<VaultMenuAction> _getMenuActions() {
    // For shared items, show limited actions
    if (widget.isSharedItem) {
      return _getSharedItemActions();
    }

    if (widget.item.type == 'folder') {
      // Case: folder
      return <VaultMenuAction>[
        VaultMenuAction(
          title: 'Edit',
          icon: AppImages.edit,
          onTap: widget.onEdit,
        ),
        VaultMenuAction(
          title: 'Move',
          icon: AppImages.move,
          onTap: widget.onMove,
        ),
        VaultMenuAction(
          title: 'Delete',
          icon: AppImages.delete,
          isDelete: true,
          onTap: widget.onDelete,
        ),
      ];
    } else {
      // Case: anything else (media, document, secureNote, etc.)
      return <VaultMenuAction>[
        VaultMenuAction(
          title: 'Preview',
          icon: AppImages.preview,
          onTap: () => _navigateToPreview(),
        ),
        VaultMenuAction(
          title: 'Download',
          icon: AppImages.download,
          onTap: () => _navigateToPreview(),
        ),
        VaultMenuAction(
          title: 'Set Reminder',
          icon: AppImages.setreminder,
          onTap: () {
            DialogHelper.showAnimatedDialog(
              context: context,
              child: SetReminderWidget(
                title: "Set Reminder",
                itemId: widget.item.id,
              ),
            );
          },
        ),
        ..._commonActions(), // include edit, move, delete if needed
      ];
    }
  }

  List<VaultMenuAction> _getSharedItemActions() {
    if (widget.item.type == 'folder') {
      return <VaultMenuAction>[
        VaultMenuAction(
          title: 'Open',
          icon: AppImages.folder,
          onTap: widget.onTap,
        ),
      ];
    } else {
      return <VaultMenuAction>[
        VaultMenuAction(
          title: 'Preview',
          icon: AppImages.preview,
          onTap: widget.onTap ?? () => _navigateToPreview(),
        ),
        VaultMenuAction(
          title: 'Download',
          icon: AppImages.download,
          onTap: widget.onTap ?? () => _navigateToPreview(),
        ),
      ];
    }
  }

  List<VaultMenuAction> _commonActions() => <VaultMenuAction>[
    VaultMenuAction(title: 'Edit', icon: AppImages.edit, onTap: widget.onEdit),
    VaultMenuAction(title: 'Move', icon: AppImages.move, onTap: widget.onMove),
    VaultMenuAction(
      title: 'Delete',
      icon: AppImages.delete,
      isDelete: true,
      onTap: widget.onDelete,
    ),
  ];

  void _navigateToPreview() {
    if (widget.item.isLocked) {
      Get.to(
        () => VerifyPinScreen(
          itemId: widget.item.id,
          onSuccess: () {
            Get.off(() => ItemPreviewScreen(item: widget.item));
          },
        ),
      );
    } else {
      Get.to(() => ItemPreviewScreen(item: widget.item));
    }
  }

  // ---------------------------------------------------------------------------
  // MENU ITEM WIDGET
  // ---------------------------------------------------------------------------

  Widget _menuItem(VaultMenuAction action) {
    return InkWell(
      onTap: () {
        _removeOverlay();
        action.onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(
              action.icon,
              color: action.isDelete
                  ? null
                  : ScreenHelper.isdarkMode(context)
                  ? Colors.white
                  : Colors.black,
            ),
            const SizedBox(width: 6),
            Text(
              action.title,
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

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    void navigateToDetails() {
      if (widget.item.type == 'folder') {
        Get.to(
          () => FolderViewScreen(item: widget.item),
          preventDuplicates: false,
        );
      } else {
        Get.to(() => ItemPreviewScreen(item: widget.item));
      }
    }

    return GestureDetector(
      onTap: () {
        debugPrint('🔵 VaultItem tapped: ${widget.item.name}, isSharedItem: ${widget.isSharedItem}, hasOnTap: ${widget.onTap != null}');
        
        // Use custom onTap if provided (for shared items)
        if (widget.onTap != null) {
          debugPrint('🔵 VaultItem: Calling custom onTap for ${widget.item.name}');
          widget.onTap!();
          return;
        }

        if (widget.item.isLocked) {
          Get.to(
            () => VerifyPinScreen(
              itemId: widget.item.id,
              onSuccess: navigateToDetails,
            ),
          );
        } else {
          navigateToDetails();
        }
      },
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  key: _itemKey,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF292416)
                        : const Color(0xFFf4edd7),
                    borderRadius: BorderRadius.circular(12),
                    border: const GradientBoxBorder(
                      gradient: LinearGradient(colors: AppColors.gradient),
                    ),
                  ),
                  child: Center(
                    child: FileTypeImageWidget(type: widget.item.name),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        widget.item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    if (widget.item.isLocked) ...<Widget>[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.lock,
                        size: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                key: _moreKey,
                onTap: _toggleMenu,
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(Icons.more_vert, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FileTypeImageWidget extends StatelessWidget {
  const FileTypeImageWidget({
    super.key,
    required this.type,
    this.height,
    this.width,
  });
  final String type; // e.g., "media", "folder", "note"
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    // Map file type to corresponding SVG
    String asset;
    switch (type.toLowerCase()) {
      case 'media':
        asset = AppImages.bell;
        break;
      case 'folder':
        asset = AppImages.folder; // replace with your folder image
        break;
      case 'note':
        asset = AppImages.activitylog; // replace with your note image
        break;
      case 'document':
        asset = AppImages.pdficon;
      default:
        asset = AppImages.folder; // fallback image
    }

    return type.contains('.')
        ? FileIcon(
            // File name
            type,

            // Icon size
            size: 50,
          )
        : SvgPicture.asset(AppImages.selected1, height: double.infinity);
  }
}
