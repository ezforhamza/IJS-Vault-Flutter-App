import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.title,
    this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.validator,
    this.controller,
    this.minLines = 1,
    this.maxLines = 1,
    this.onChanged,
    this.isTitle = true,
    this.suffixIcon,
    this.readOnly = false,
  });

  final String title;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final ValueChanged<String>? onChanged;

  final bool isPassword;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final int minLines;
  final int maxLines;
  final bool isTitle;
  final bool readOnly;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  // bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.isTitle)
          Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(fontSize: 14),
          ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: widget.readOnly,
          controller: widget.controller,
          onChanged: widget.onChanged, // ✅ added

          obscureText: widget.isPassword ? _obscureText : false,

          validator: (String? value) {
            final String? error = widget.validator?.call(value);
            // setState(() {
            //   _hasError = error != null;
            // });
            return error;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          cursorColor: const Color(0xFFa4a4a4),
          style: const TextStyle(color: Color(0xFFa4a4a4), fontSize: 12),
          minLines: widget.minLines,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          decoration: InputDecoration(
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
            helperText: ' ',
            filled: true,
            fillColor: isDarkMode
                ? const Color(0xFF20222b)
                : const Color(0xFFfdfbf5),
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white54 : const Color(0xFFa4a4a4),
              fontSize: 13,
            ),
            // isCollapsed: ,
            isDense: true,
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
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: widget.suffixIcon,
                  ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
