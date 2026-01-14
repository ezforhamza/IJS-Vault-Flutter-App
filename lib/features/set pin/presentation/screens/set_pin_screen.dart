import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/features/set%20pin/presentation/screens/confirm_pin_screen.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key, this.itemId});
  final String? itemId;

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _enteredPin => _controllers.map((c) => c.text).join();

  void _onPinChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-navigate when all 4 digits entered
    if (_enteredPin.length == 4) {
      FocusScope.of(context).unfocus();
      Get.to(
        () => ConfirmPinScreen(
          itemId: widget.itemId,
          firstPin: _enteredPin,
        ),
      );
    }
  }

  void _onKeyPressed(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0a0a0a) : Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Lock Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            AppColors.gradient[0].withValues(alpha: 0.2),
                            AppColors.gradient[1].withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 40,
                        color: AppColors.gradient[0],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Set PIN',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Create a 4-digit PIN to protect this item',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // PIN Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          width: 60,
                          height: 60,
                          margin: EdgeInsets.only(
                            right: index < 3 ? 16 : 0,
                          ),
                          child: RawKeyboardListener(
                            focusNode: FocusNode(),
                            onKey: (event) => _onKeyPressed(index, event),
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              obscureText: true,
                              obscuringCharacter: '●',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: isDarkMode
                                    ? const Color(0xFF1a1a1a)
                                    : const Color(0xFFf5f5f5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.gradient[0],
                                    width: 2,
                                  ),
                                ),
                              ),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) => _onPinChanged(index, value),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    // Helper text
                    Text(
                      'PIN will auto-submit when complete',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
