import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:image_picker/image_picker.dart';

class PfpSelectionWidget extends StatefulWidget {
  const PfpSelectionWidget({super.key, required this.onImageSelected});

  /// Returns selected image file
  final ValueChanged<File> onImageSelected;

  @override
  State<PfpSelectionWidget> createState() => _PfpSelectionWidgetState();
}

class _PfpSelectionWidgetState extends State<PfpSelectionWidget> {
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      setState(() => _imageFile = file);
      widget.onImageSelected(file); // 🔥 return file
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return GestureDetector(
      onTap: _pickImage,
      child: SizedBox(
        height: 100,
        width: 100,
        child: Stack(
          children: <Widget>[
            Center(
              child: ClipOval(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF34353d)
                        : const Color(0xFFf7f7f7),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
              ),
            ),

            if (_imageFile == null)
              Center(
                child: SvgPicture.asset(
                  AppImages.pfpicon2,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),

            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFdbdbdb),
                  border: Border.all(
                    color: isDarkMode ? Colors.black : Colors.white,
                    width: 3,
                  ),
                ),
                child: SvgPicture.asset(AppImages.pfpicon1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
