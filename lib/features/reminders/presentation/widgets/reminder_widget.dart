import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/reminders/data/models/reminders_model.dart';
import 'package:ijs_vault/features/reminders/presentation/controllers/reminder_controller.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

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

          // Associated Item Info
          Row(
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
                    // Assuming description holds size or similar info if relevant,
                    // otherwise just show type
                    Text(
                      widget.reminder.itemType.toUpperCase(),
                      style: textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
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
}
