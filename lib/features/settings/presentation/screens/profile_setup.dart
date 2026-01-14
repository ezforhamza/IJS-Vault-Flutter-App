import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ijs_vault/core/constants/app_assets.dart';
import 'package:ijs_vault/core/constants/app_sizes.dart';
import 'package:ijs_vault/core/controllers/profile_controller.dart';
import 'package:ijs_vault/features/auth/presentation/widgets/pfp_selection_widget.dart';
import 'package:ijs_vault/features/settings/presentation/controllers/change_profile_controller.dart';
import 'package:ijs_vault/shared/widgets/app_bar.dart';
import 'package:ijs_vault/shared/widgets/custom_button.dart';
import 'package:ijs_vault/shared/widgets/custom_text_field.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late final ChangeProfileController controller;
  final ProfileController _profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChangeProfileController());
    _loadUserData();
  }

  void _loadUserData() {
    final user = _profileController.currentUser.value;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'Profile Setup'),
      body: Padding(
        padding: AppSizes.horizontalPadding,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 30),

                /// Profile Picture
                Center(
                  child: Obx(() => PfpSelectionWidget(
                    onImageSelected: controller.setProfilePicture,
                    initialImageUrl: _profileController.currentUser.value?.image,
                  )),
                ),

                const SizedBox(height: 30),

                /// Full Name
                CustomTextField(
                  controller: _fullNameController,
                  title: 'Full Name',
                  hintText: 'Enter Full Name',
                  prefixIcon: SvgPicture.asset(
                    AppImages.profile,
                    color: const Color(0xFFB2B2B2),
                  ),
                  validator: (String? value) {
                    if (_phoneController.text.isNotEmpty &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),

                /// Email (Read-only)
                CustomTextField(
                  controller: _emailController,
                  title: 'Email Address',
                  // enabled: false,
                  prefixIcon: SvgPicture.asset(
                    AppImages.email,
                    color: const Color(0xFFB2B2B2),
                  ),
                ),

                /// Phone
                CustomTextField(
                  controller: _phoneController,
                  title: 'Phone Number',
                  hintText: 'Enter Phone Number',
                  prefixIcon: SvgPicture.asset(
                    AppImages.phone,
                    color: const Color(0xFFB2B2B2),
                  ),
                  validator: (String? value) {
                    if (_fullNameController.text.isNotEmpty &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                /// Update Button
                CustomButton(
                  text: 'Update',
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      controller.updateProfile(
                        newFullName: _fullNameController.text.trim().isNotEmpty
                            ? _fullNameController.text.trim()
                            : null,
                        newPhone: _phoneController.text.trim().isNotEmpty
                            ? _phoneController.text.trim()
                            : null,
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
