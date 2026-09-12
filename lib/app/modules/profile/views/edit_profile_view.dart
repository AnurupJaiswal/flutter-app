import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "Alex Rivers");
  final _emailController = TextEditingController(text: "alex@rivers.com");
  final _phoneController = TextEditingController(text: "+1 (555) 019-2834");
  final _bioController = TextEditingController(text: "Content creator & AI enthusiast");

  bool _isSaving = false;
  final int _bioMaxLength = 160;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isSaving = false);
    if (!mounted) return;
    Navigator.of(context).pop();
    AppToast.success("Your profile has been saved successfully.");
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: true,
            title: "Edit Profile",
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Photo Section ───────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: CC.primary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: CC.primary.withValues(alpha: 0.25),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _nameController.text.isNotEmpty
                                        ? _nameController.text[0].toUpperCase()
                                        : "A",
                                    style: TS.displayLarge(
                                      color: CC.primary,
                                      fontWeight: FontWeight.w600,
                                    ).copyWith(fontSize: 34),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  AppToast.info("Photo selection coming soon.");
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: CC.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: CC.background,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          10.height,
                          Text(
                            "Change profile photo",
                            style: TS.caption(color: CC.textSecondary).copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    28.height,

                    // ── Personal Information Section ───────────────────────
                    Text(
                      "Personal Information",
                      style: TS.sectionTitle(
                        color: CC.textPrimary,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 15),
                    ),
                    14.height,
                    _buildTextField(
                      label: "Full Name",
                      controller: _nameController,
                      hint: "Enter your full name",
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Name is required" : null,
                      textInputAction: TextInputAction.next,
                    ),
                    14.height,
                    _buildTextField(
                      label: "Email Address",
                      controller: _emailController,
                      hint: "Enter your email address",
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Email is required";
                        if (!v.contains("@")) return "Enter a valid email";
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    14.height,
                    _buildTextField(
                      label: "Phone Number",
                      controller: _phoneController,
                      hint: "Enter your phone number",
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    28.height,

                    // ── Creator Bio Section ────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Creator Bio",
                          style: TS.sectionTitle(
                            color: CC.textPrimary,
                            fontWeight: FontWeight.w600,
                          ).copyWith(fontSize: 15),
                        ),
                        ValueListenableBuilder(
                          valueListenable: _bioController,
                          builder: (context, value, child) {
                            return Text(
                              "${value.text.length}/$_bioMaxLength",
                              style: TS.caption(
                                color: value.text.length > _bioMaxLength
                                    ? CC.error
                                    : CC.grey,
                              ).copyWith(fontSize: 12),
                            );
                          },
                        ),
                      ],
                    ),
                    10.height,
                    _buildBioField(),
                    8.height,
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        "This will appear on your creator profile.",
                        style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12),
                      ),
                    ),
                    32.height,

                    // ── Save Changes CTA ───────────────────────────────────
                    CW.commonBtn(
                      title: "Save Changes",
                      isLoading: _isSaving,
                      onTap: _save,
                    ),
                    24.height,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Form Field Builder ───────────────────────────────────────────────────
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TS.caption(
            color: CC.textSecondary,
            fontWeight: FontWeight.w500,
          ).copyWith(fontSize: 13),
        ),
        6.height,
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          style: TS.bodyMedium(
            color: CC.textPrimary,
            fontWeight: FontWeight.w400,
          ),
          cursorColor: CC.primary,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: TS.bodyMedium(color: CC.grey.withValues(alpha: 0.7)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: CC.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: CC.stroke,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: CC.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: CC.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: CC.error,
                width: 1.5,
              ),
            ),
            errorStyle: TS.caption(color: CC.error).copyWith(fontSize: 11),
          ),
        ),
      ],
    );
  }

  // ── Bio Text Area Builder ─────────────────────────────────────────────────
  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      maxLines: 4,
      maxLength: _bioMaxLength,
      style: TS.bodyMedium(
        color: CC.textPrimary,
        fontWeight: FontWeight.w400,
      ).copyWith(height: 1.4),
      cursorColor: CC.primary,
      decoration: InputDecoration(
        counterText: "", // hidden here, shown in section header
        hintText: "Tell people a little about yourself...",
        hintStyle: TS.bodyMedium(color: CC.grey.withValues(alpha: 0.7)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: CC.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: CC.stroke,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: CC.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
