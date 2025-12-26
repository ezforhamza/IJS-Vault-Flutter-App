import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:ijs_vault/core/constants/app_colors.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

class OtpInput extends StatefulWidget {
  final int length;
  const OtpInput({super.key, this.length = 6});

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  // final int length = 6;
  final List<TextEditingController> controllers = [];
  final List<FocusNode> focusNodes = [];

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
    for (var controller in controllers) controller.dispose();
    for (var node in focusNodes) node.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < widget.length - 1) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ScreenHelper.isdarkMode(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        const maxBoxSize = 50.0;
        final totalSpacing = spacing * (widget.length - 1);

        // Available width for boxes
        final availableWidth = constraints.maxWidth - totalSpacing;

        // Calculate box size but NEVER exceed maxBoxSize
        final boxSize = (availableWidth / widget.length).clamp(
          40.0,
          maxBoxSize,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            final isFilled = controllers[index].text.isNotEmpty;

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
                              ? const Color(0xFF20222b)
                              : const Color(0xFFfefdf6))
                        : (isDarkMode
                              ? const Color(0xFF2C2C36)
                              : const Color(0xFFfbf9f2)),
                    borderRadius: BorderRadius.circular(8),
                    border: isFilled
                        ? GradientBoxBorder(
                            gradient: const LinearGradient(
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
                      fontSize: boxSize * 0.35, // scale text nicely
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFa4a4a4),
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => _onChanged(value, index),
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
