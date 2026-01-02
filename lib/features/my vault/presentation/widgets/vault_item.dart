import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

class VaultItem extends StatefulWidget {
  const VaultItem({super.key});

  @override
  State<VaultItem> createState() => _VaultItemState();
}

class _VaultItemState extends State<VaultItem> {
  final GlobalKey _itemKey = GlobalKey();
  final GlobalKey _moreKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;
  bool _isDisposed = false;

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
  // Overlay Control
  // -------------------------------

  void _toggleMenu() {
    _isMenuOpen ? _removeOverlay() : _showOverlay();
  }

  void _showOverlay() {
    if (_isDisposed || _overlayEntry != null) return;

    // Get icon render box
    final RenderBox iconBox =
        _moreKey.currentContext!.findRenderObject() as RenderBox;
    final Offset iconOffset = iconBox.localToGlobal(Offset.zero);
    final double iconHeight = iconBox.size.height;

    // VaultItem container
    final RenderBox itemBox =
        _itemKey.currentContext!.findRenderObject() as RenderBox;
    final double overlayWidth = itemBox.size.width; // same as card
    final double itemLeft = itemBox.localToGlobal(Offset.zero).dx; // left edge

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        final bool isDarkMode = Get.isDarkMode;

        return Stack(
          children: <Widget>[
            // Tap outside
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => _removeOverlay(),
                child: const SizedBox.expand(),
              ),
            ),

            // Overlay positioned right below icon but aligned left to card
            Positioned(
              left: itemLeft, // left aligned to VaultItem
              top: iconOffset.dy + iconHeight + 6, // just below icon
              width: overlayWidth,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.white,
                    // borderRadius: BorderRadius.circular(8),
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
                      _menuItem(
                        title: 'Rename',
                        icon: AppImages.delete,
                        isDelete: false,
                      ),
                      _menuItem(
                        title: 'Move',
                        icon: AppImages.delete,
                        isDelete: false,
                      ),
                      const Divider(),
                      _menuItem(
                        title: 'Delete',
                        icon: AppImages.delete,
                        isDelete: true,
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
    setState(() => _isMenuOpen = true);
  }

  void _removeOverlay({bool fromDispose = false}) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (fromDispose || !mounted || _isDisposed) return;
    setState(() => _isMenuOpen = false);
  }

  // -------------------------------
  // Menu Item
  // -------------------------------

  Widget _menuItem({
    required String title,
    required String icon,
    required bool isDelete,
  }) {
    return InkWell(
      onTap: () => _removeOverlay(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(
              icon,
              color: isDelete
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
    final bool isDarkMode = Get.isDarkMode;

    return Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
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
                child: SvgPicture.asset(
                  AppImages.selected1,
                  height: 70,
                  width: 70,
                  // fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Images',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 6,
          right: 6,
          child: InkWell(
            key: _moreKey,
            onTap: _toggleMenu,
            child: const Icon(Icons.more_vert, size: 16),
          ),
        ),
      ],
    );
  }
}
