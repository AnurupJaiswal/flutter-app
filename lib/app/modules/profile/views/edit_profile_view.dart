import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

  /// Locally picked image. Null until the user selects one.
  File? _pickedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // ── Image Source Sheet ───────────────────────────────────────────────────

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,           // prevents overflow on small screens
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            // Never taller than 85% of the screen — avoids overflow
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: CC.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: CC.stroke,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      "Change Profile Photo",
                      style: TS.sectionTitle(
                        color: CC.textPrimary,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 16),
                    ),
                    4.height,
                    Text(
                      "Choose how you'd like to update your photo",
                      style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12),
                    ),
                    20.height,
                    _SourceTile(
                      icon: Icons.camera_alt_rounded,
                      label: "Take a Photo",
                      subtitle: "Open camera to snap a new photo",
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    12.height,
                    _SourceTile(
                      icon: Icons.photo_library_rounded,
                      label: "Choose from Gallery",
                      subtitle: "Select an existing photo from your library",
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    if (_pickedImage != null) ...[  
                      12.height,
                      _SourceTile(
                        icon: Icons.delete_outline_rounded,
                        label: "Remove Photo",
                        subtitle: "Revert to your initials avatar",
                        iconColor: CC.error,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          setState(() => _pickedImage = null);
                        },
                      ),
                    ],
                    20.height,
                    CW.commonBtn(
                      title: "Cancel",
                      isOutlined: true,
                      height: 46,
                      onTap: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Calls image_picker which triggers the native OS permission dialog
  /// automatically before opening camera or gallery.
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked == null) return; // user cancelled
      setState(() => _pickedImage = File(picked.path));
      AppToast.success("Profile photo updated!");
    } catch (e) {
      // image_picker throws a PlatformException when the user denies permission.
      final msg = e.toString().toLowerCase();
      if (msg.contains('permission') ||
          msg.contains('denied') ||
          msg.contains('access')) {
        _showPermissionDeniedDialog(source);
      } else {
        AppToast.error("Could not pick image. Please try again.");
      }
    }
  }

  void _showPermissionDeniedDialog(ImageSource source) {
    final isCamera = source == ImageSource.camera;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: CC.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "${isCamera ? 'Camera' : 'Gallery'} Access Required",
          style: TS
              .sectionTitle(color: CC.textPrimary, fontWeight: FontWeight.w600)
              .copyWith(fontSize: 16),
        ),
        content: Text(
          isCamera
              ? "Lala AI needs camera access to take your profile photo. "
                  "Please go to Settings → Apps → Lala AI → Permissions and enable Camera."
              : "Lala AI needs photo library access so you can pick a profile picture. "
                  "Please go to Settings → Apps → Lala AI → Permissions and enable Photos.",
          style: TS.body(color: CC.textSecondary).copyWith(fontSize: 13, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text("Not Now",
                style: TS.bodyMedium(color: CC.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              AppToast.info(
                  "Go to Settings → Apps → Lala AI → Permissions");
            },
            child: Text("Open Settings",
                style: TS.bodyMedium(
                    color: CC.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
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
                          GestureDetector(
                            onTap: _showImageSourceSheet,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                // Avatar: picked image OR initials fallback
                                _AvatarWidget(
                                  imageFile: _pickedImage,
                                  initials: _nameController.text.isNotEmpty
                                      ? _nameController.text[0].toUpperCase()
                                      : "A",
                                ),
                                // Camera badge
                                Container(
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
                                        color: CC.black.withValues(alpha: 0.15),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: CC.whiteText,
                                    size: 15,
                                  ),
                                ),
                              ],
                            ),
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
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Name is required" : null,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}), // refresh initials avatar
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
    ValueChanged<String>? onChanged,
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
          onChanged: onChanged,
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

// ── _AvatarWidget ─────────────────────────────────────────────────────────────
/// Shows [imageFile] center-cropped into a perfect circle.
/// Falls back to an initials circle when no image is set.
class _AvatarWidget extends StatelessWidget {
  final File? imageFile;
  final String initials;

  const _AvatarWidget({required this.imageFile, required this.initials});

  @override
  Widget build(BuildContext context) {
    // ClipOval is the only reliable way to get a perfect circle crop on both
    // Android and iOS — Container+BoxShape.circle does not clip its child.
    return Stack(
      alignment: Alignment.center,
      children: [
        // Border ring drawn underneath the clip so it shows outside the image
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CC.primary.withValues(alpha: 0.12),
            border: Border.all(
              color: CC.primary.withValues(alpha: 0.35),
              width: 2.5,
            ),
          ),
        ),
        // ClipOval guarantees center-cropped circle
        ClipOval(
          child: SizedBox(
            width: 96,
            height: 96,
            child: imageFile != null
                ? Image.file(
                    imageFile!,
                    fit: BoxFit.cover,   // fills the 96×96 square then clips to circle
                    width: 96,
                    height: 96,
                    errorBuilder: (_, __, ___) => _Initials(initials: initials),
                  )
                : _Initials(initials: initials),
          ),
        ),
      ],
    );
  }
}

class _Initials extends StatelessWidget {
  final String initials;
  const _Initials({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TS
            .displayLarge(color: CC.primary, fontWeight: FontWeight.w600)
            .copyWith(fontSize: 34),
      ),
    );
  }
}

// ── _SourceTile ───────────────────────────────────────────────────────────────
/// A tappable row inside the image-source bottom sheet.
class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? CC.primary;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: CC.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              14.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TS.bodyMedium(
                        color: iconColor ?? CC.textPrimary,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 14),
                    ),
                    2.height,
                    Text(
                      subtitle,
                      style: TS.caption(color: CC.textSecondary)
                          .copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: CC.textSecondary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
