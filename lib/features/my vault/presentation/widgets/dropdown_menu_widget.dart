import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/features/my%20vault/data/models/linkable_user_model.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
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
  String? _selectedUserId;
  final GlobalKey _dropdownKey = GlobalKey();
  final GlobalKey _userDropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  OverlayEntry? _userOverlayEntry;
  bool _isMenuOpen = false;
  bool _isUserMenuOpen = false;
  bool _isDisposed = false;

  final MyVaultController _controller = Get.find<MyVaultController>();

  // Expose selected data
  String? get selectedUserId => _selectedUserId;
  String get selectedAccess => _selectedAccess;

  @override
  void didChangeDependencies() {
    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      _removeOverlay();
      _removeUserOverlay();
      return true;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _removeOverlay(fromDispose: true);
    _removeUserOverlay(fromDispose: true);
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    if (value.trim().isNotEmpty) {
      _controller.searchUsersForLinking(value);
      if (!_isUserMenuOpen) {
        _showUserOverlay();
      }
    } else {
      _controller.linkableUsers.clear();
      _removeUserOverlay();
    }
  }

  void _selectUser(LinkableUser user) {
    _emailController.text = user.email;
    _selectedUserId = user.id;
    _removeUserOverlay();
  }

  // Access dropdown methods
  void _toggleMenu() {
    if (_isMenuOpen) {
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
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) {
                  _removeOverlay();
                },
                child: const SizedBox.expand(),
              ),
            ),
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
                      _buildMenuItem('View'),
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

  // User dropdown methods
  void _showUserOverlay() {
    final RenderBox renderBox =
        _userDropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _userOverlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) {
                  _removeUserOverlay();
                },
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              width: size.width,
              child: Material(
                color: Colors.transparent,
                child: Obx(() {
                  if (_controller.isSearchingUsers.value) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ScreenHelper.isdarkMode(context)
                            ? Colors.black
                            : Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (_controller.linkableUsers.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ScreenHelper.isdarkMode(context)
                            ? Colors.black
                            : Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        'No users found',
                        style: TextStyle(
                          color: ScreenHelper.isdarkMode(context)
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    );
                  }

                  return Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: ScreenHelper.isdarkMode(context)
                          ? Colors.black
                          : Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _controller.linkableUsers.length,
                      itemBuilder: (BuildContext context, int index) {
                        final LinkableUser user =
                            _controller.linkableUsers[index];
                        return InkWell(
                          onTap: () => _selectUser(user),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: user.image != null
                                      ? NetworkImage(user.image!)
                                      : null,
                                  child: user.image == null
                                      ? Text(user.fullName[0].toUpperCase())
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        user.fullName,
                                        style: TextStyle(
                                          color:
                                              ScreenHelper.isdarkMode(context)
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                          color:
                                              ScreenHelper.isdarkMode(context)
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_userOverlayEntry!);

    if (mounted) {
      setState(() => _isUserMenuOpen = true);
    }
  }

  void _removeUserOverlay({bool fromDispose = false}) {
    _userOverlayEntry?.remove();
    _userOverlayEntry = null;

    if (fromDispose || !mounted || _isDisposed) return;

    if (_isUserMenuOpen) {
      setState(() => _isUserMenuOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final bool isDarkMode = Get.isDarkMode;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF20222b) : const Color(0xFFfdfbf5),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                key: _userDropdownKey,
                child: TextFormField(
                  controller: _emailController,
                  onChanged: _onEmailChanged,
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
              Container(width: 2, height: 60, color: const Color(0xFFa4a4a4)),
              InkWell(
                key: _dropdownKey,
                onTap: _toggleMenu,
                child: SizedBox(
                  width: 130,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            _selectedAccess,
                            style: const TextStyle(color: Color(0xFF606060)),
                            maxLines: 2,
                          ),
                        ),
                        Icon(
                          _isMenuOpen
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
