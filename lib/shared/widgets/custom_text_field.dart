import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/shared/helpers/screen_helper.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.title,
    this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.validator,
    this.controller,
  });

  final String title;
  final String? hintText;
  final Widget? prefixIcon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = ScreenHelper.isdarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.title,
          style: Theme.of(
            context,
          ).textTheme.labelMedium!.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          validator: (String? value) {
            final String? error = widget.validator?.call(value);
            setState(() {
              _hasError = error != null;
            });
            return error;
          },
          cursorColor: const Color(0xFFa4a4a4),
          style: const TextStyle(color: Color(0xFFa4a4a4)),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDarkMode
                ? const Color(0xFF20222b)
                : const Color(0xFFfdfbf5),
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white54 : const Color(0xFFa4a4a4),
              fontSize: 14,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: widget.prefixIcon,
                  )
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: SvgPicture.asset(AppImages.eye1),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            // No border by default
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: BorderSide.none,
            ),
            // Show red border only on validation error
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
