import 'package:flutter/material.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

class CustomTextFieldWithDropdown extends StatefulWidget {
  const CustomTextFieldWithDropdown({super.key});

  @override
  State<CustomTextFieldWithDropdown> createState() =>
      _CustomTextFieldWithDropdownState();
}

class _CustomTextFieldWithDropdownState
    extends State<CustomTextFieldWithDropdown> {
  final TextEditingController _emailController = TextEditingController();
  String _selectedAccess = 'Select Access';
  bool _isDropdownOpen = false;
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _emailController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Stack(
          children: <Widget>[
            // 👇 Full screen tap detector
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) {
                  _removeOverlay();
                },
                child: const SizedBox.expand(),
              ),
            ),

            // 👇 Dropdown menu
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              width: size.width,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: ScreenHelper.isdarkMode(context)
                        ? Colors.black
                        : Colors.white,
                    // borderRadius: BorderRadius.circular(8),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildMenuItem('Edit'),
                      _buildMenuItem('View Only'),
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
    setState(() => _isDropdownOpen = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  Widget _buildMenuItem(String value) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedAccess = value;
        });
        _removeOverlay();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Text(
          value,
          style: TextStyle(
            color: ScreenHelper.isdarkMode(context)
                ? Colors.white
                : Colors.black,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF20222b) : const Color(0xFFfdfbf5),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  validator: (String? value) {
                    return null;
                  },
                  cursorColor: const Color(0xFFa4a4a4),
                  style: const TextStyle(color: Color(0xFFa4a4a4)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: 'Enter Email of Linked User',
                    hintStyle: TextStyle(
                      color: isDarkMode
                          ? Colors.white54
                          : const Color(0xFFa4a4a4),
                      fontSize: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                ),
              ),
              // Vertical Divider
              Container(width: 2, height: 55, color: const Color(0xFFa4a4a4)),
              // Dropdown Button
              // Dropdown Button
              InkWell(
                key: _dropdownKey,
                onTap: _toggleDropdown,
                child: SizedBox(
                  width: 130, // fixed width for dropdown
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            _selectedAccess,
                            style: const TextStyle(
                              color: Color(0xFF606060),
                              // fontSize: 13,
                            ),
                            // overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        Icon(
                          _isDropdownOpen
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: isDarkMode ? Colors.white : Colors.black,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
