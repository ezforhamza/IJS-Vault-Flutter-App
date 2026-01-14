import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/features/my%20vault/presentation/controllers/my_vault_controller.dart';
import 'package:ijs_vault/features/set%20pin/presentation/widgets/success_dialogue_widget.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';
import 'package:ijs_vault/shared/helpers/toasts.dart';

class ConfirmPinScreen extends StatefulWidget {
  const ConfirmPinScreen({super.key, this.itemId, this.firstPin});
  final String? itemId;
  final String? firstPin;

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends State<ConfirmPinScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isProcessing = false;
  bool _hasError = false;
  String? _errorMessage;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

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
    _shakeController.dispose();
    super.dispose();
  }

  String get _enteredPin => _controllers.map((c) => c.text).join();

  void _onPinChanged(int index, String value) {
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
    }

    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-submit when all 4 digits entered
    if (_enteredPin.length == 4) {
      _confirmPin();
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

  Future<void> _confirmPin() async {
    if (_isProcessing) return;

    // Check if PINs match
    if (widget.firstPin != null && widget.firstPin != _enteredPin) {
      setState(() {
        _hasError = true;
        _errorMessage = 'PINs do not match';
      });
      _shakeController.forward().then((_) => _shakeController.reset());
      _clearPin();
      return;
    }

    setState(() => _isProcessing = true);
    FocusScope.of(context).unfocus();

    if (widget.itemId != null) {
      final MyVaultController controller = Get.find<MyVaultController>();
      final bool success = await controller.setItemPin(
        itemId: widget.itemId!,
        pin: _enteredPin,
      );

      if (success) {
        _showSuccessDialog();
      } else {
        setState(() {
          _isProcessing = false;
          _hasError = true;
          _errorMessage = 'Failed to set PIN';
        });
        _shakeController.forward().then((_) => _shakeController.reset());
        _clearPin();
      }
    } else {
      _showSuccessDialog();
    }
  }

  void _clearPin() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Success',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: SuccessDialogue(
            h: ScreenHelper.height(context),
            theme: Theme.of(context).textTheme,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final CurvedAnimation curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curvedAnimation, child: child),
        );
      },
    );
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
                        Icons.check_circle_outline_rounded,
                        size: 40,
                        color: AppColors.gradient[0],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Confirm PIN',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Re-enter your PIN to confirm',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // PIN Input Fields with shake animation
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        final double shake = _shakeAnimation.value * 10;
                        return Transform.translate(
                          offset: Offset(
                            shake * ((_shakeAnimation.value * 10).toInt().isEven ? 1 : -1),
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: Row(
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
                                  color: _hasError
                                      ? Colors.red
                                      : (isDarkMode ? Colors.white : Colors.black),
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? (_hasError
                                          ? Colors.red.withValues(alpha: 0.1)
                                          : const Color(0xFF1a1a1a))
                                      : (_hasError
                                          ? Colors.red.withValues(alpha: 0.05)
                                          : const Color(0xFFf5f5f5)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: _hasError
                                          ? Colors.red.withValues(alpha: 0.5)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: _hasError
                                          ? Colors.red
                                          : AppColors.gradient[0],
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
                    ),

                    const SizedBox(height: 24),

                    // Error message
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _hasError && _errorMessage != null
                          ? Container(
                              key: const ValueKey('error'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(key: ValueKey('empty'), height: 32),
                    ),

                    const SizedBox(height: 32),

                    // Loading indicator
                    if (_isProcessing)
                      Column(
                        children: <Widget>[
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.gradient[0],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Setting PIN...',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white54 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
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
