import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

class ReminderWidget extends StatefulWidget {
  const ReminderWidget({super.key});

  @override
  State<ReminderWidget> createState() => _ReminderWidgetState();
}

class _ReminderWidgetState extends State<ReminderWidget> {
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
        final bool isDarkMode = ScreenHelper.isdarkMode(context);

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
                      _buildMenuItem(
                        title: 'Mark Complete',
                        image: AppImages.markcomplete,
                        isdel: false,
                      ),
                      _buildMenuItem(
                        title: 'Mark Pending',
                        image: AppImages.bell2,
                        isdel: false,
                      ),
                      const Divider(),
                      _buildMenuItem(
                        title: 'Delete',
                        image: AppImages.delete,
                        isdel: true,
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
  }) {
    return InkWell(
      onTap: () => _removeOverlay(),
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
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF20222b) : Colors.white,
        border: Border.all(
          color: isDarkMode ? const Color(0xFF47443b) : const Color(0xFFf7f2e0),
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('Letter for job', style: textTheme.labelMedium),
              const Spacer(),
              InkWell(
                key: _moreKey,
                onTap: _toggleMenu,
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              SvgPicture.asset(AppImages.pdf),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Cover Letter', style: textTheme.labelMedium),
                  Text('867 KB', style: textTheme.labelSmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Scanned copy of my Cover Letter.',
            style: textTheme.labelSmall!.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: 'Reminder Date & Time: ',
                  style: textTheme.labelMedium,
                ),
                TextSpan(
                  text: '20 Oct, 2025 - 8:00',
                  style: textTheme.labelSmall!.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
