import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 6,
    this.onOtpChanged,
    this.isOtpWrong = false, // ✅ new parameter
  });

  final int length;
  final ValueChanged<String>? onOtpChanged;
  final bool isOtpWrong; // ✅ indicates wrong OTP

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final List<TextEditingController> controllers = <TextEditingController>[];
  final List<FocusNode> focusNodes = <FocusNode>[];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.length; i++) {
      controllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in controllers) {
      controller.dispose();
    }
    for (final FocusNode node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getOtp() {
    return controllers.map((TextEditingController c) => c.text).join();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < widget.length - 1) {
      focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    widget.onOtpChanged?.call(_getOtp());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double spacing = 10.0;
        const double maxBoxSize = 50.0;
        final double totalSpacing = spacing * (widget.length - 1);
        final double availableWidth = constraints.maxWidth - totalSpacing;

        final double boxSize = (availableWidth / widget.length).clamp(
          40.0,
          maxBoxSize,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (int index) {
            final bool isFilled = controllers[index].text.isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(
                right: index == widget.length - 1 ? 0 : spacing,
              ),
              child: GestureDetector(
                onTap: () => focusNodes[index].requestFocus(),
                child: Container(
                  width: boxSize,
                  height: boxSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isFilled
                        ? (isDarkMode
                              ? const Color(0xFF20222B)
                              : const Color(0xFFFEFDF6))
                        : (isDarkMode
                              ? const Color(0xFF2C2C36)
                              : const Color(0xFFFBF9F2)),
                    borderRadius: BorderRadius.circular(8),
                    border: widget.isOtpWrong
                        ? Border.all(
                            color: Colors.red,
                            width: 2,
                          ) // ❌ show red border when wrong
                        : isFilled
                        ? const GradientBoxBorder(
                            gradient: LinearGradient(
                              colors: AppColors.gradient,
                            ),
                            width: 1,
                          )
                        : null,
                  ),
                  child: TextField(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    cursorColor: isDarkMode ? Colors.white : Colors.black,
                    style: TextStyle(
                      fontSize: boxSize * 0.35,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFA4A4A4),
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                    ),
                    onChanged: (String value) => _onChanged(value, index),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
