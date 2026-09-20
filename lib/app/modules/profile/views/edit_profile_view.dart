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
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/data/models/content_niche_model.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;
  late final TextEditingController _nicheController;
  late final TextEditingController _audienceController;
  late final TextEditingController _goalsController;

  bool _isSaving = false;
  final int _bioMaxLength = 160;

  /// Locally picked image. Null until the user selects one.
  File? _pickedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final cachedCreator = ApiService.currentCreatorProfile;
    final currentUserName = ApiService.effectiveDisplayName;
    final currentUserEmail = ApiService.currentUser?.email.isNotEmpty == true
        ? ApiService.currentUser!.email
        : (ApiService.userEmail ?? "");

    _nameController = TextEditingController(text: currentUserName);
    _emailController = TextEditingController(text: currentUserEmail);
    _bioController = TextEditingController(
      text: cachedCreator?.bio ?? "Content creator & AI enthusiast",
    );
    _nicheController = TextEditingController(
      text: cachedCreator?.niche ?? "Tech & AI",
    );
    _audienceController = TextEditingController(
      text: cachedCreator?.audienceDescription ?? "Early adopters & AI builders",
    );
    _goalsController = TextEditingController(
      text: cachedCreator?.goalsFormatted.isNotEmpty == true
          ? cachedCreator!.goalsFormatted
          : "GROWTH, MONETIZATION",
    );

    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final authRepo = Get.isRegistered<AuthRepository>()
          ? Get.find<AuthRepository>()
          : Get.put<AuthRepository>(ApiAuthRepository());

      final response = await authRepo.getCreatorProfile();
      if (response.isSuccess && response.data != null && mounted) {
        final profile = response.data!;
        setState(() {
          if (profile.displayName?.isNotEmpty == true) {
            _nameController.text = profile.displayName!;
          }
          if (profile.bio?.isNotEmpty == true) {
            _bioController.text = profile.bio!;
          }
          if (profile.niche?.isNotEmpty == true) {
            _nicheController.text = profile.niche!;
          }
          if (profile.audienceDescription?.isNotEmpty == true) {
            _audienceController.text = profile.audienceDescription!;
          }
          if (profile.goalsFormatted.isNotEmpty) {
            _goalsController.text = profile.goalsFormatted;
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _nicheController.dispose();
    _audienceController.dispose();
    _goalsController.dispose();
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

  // ── Content Niche Picker Sheet (Single Selection) ────────────────────────
  void _showNichePickerSheet() {
    final searchController = TextEditingController();
    String query = "";

    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredNiches = kContentNiches.where((niche) {
              if (query.isEmpty) return true;
              final q = query.toLowerCase();
              return niche.title.toLowerCase().contains(q);
            }).toList();

            final currentNiche = _nicheController.text.trim();

            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    16 + MediaQuery.of(sheetContext).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: CC.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(
                      color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: CC.stroke,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        "Select Content Niche",
                        style: TS.sectionTitle(
                          color: CC.textPrimary,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 17),
                      ),
                      4.height,
                      Text(
                        "Choose the niche that best represents your content focus",
                        style: TS.caption(color: CC.textSecondary)
                            .copyWith(fontSize: 12),
                      ),
                      14.height,
                      // Search bar
                      TextField(
                        controller: searchController,
                        onChanged: (val) {
                          setSheetState(() {
                            query = val.trim();
                          });
                        },
                        style: TS.bodyMedium(color: CC.textPrimary),
                        cursorColor: CC.primary,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: "Search content niches...",
                          hintStyle: TS.bodyMedium(
                                  color: CC.grey.withValues(alpha: 0.7))
                              .copyWith(fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded,
                              size: 20, color: CC.textSecondary),
                          suffixIcon: query.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded,
                                      size: 18, color: CC.textSecondary),
                                  onPressed: () {
                                    searchController.clear();
                                    setSheetState(() {
                                      query = "";
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: CC.background,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
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
                      ),
                      12.height,
                      // Niches list
                      Flexible(
                        child: filteredNiches.isEmpty
                            ? Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 36),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.search_off_rounded,
                                          color: CC.grey, size: 36),
                                      8.height,
                                      Text(
                                        "No niches matching \"$query\"",
                                        style: TS.bodySmall(
                                            color: CC.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: filteredNiches.length,
                                separatorBuilder: (_, __) => 8.height,
                                itemBuilder: (context, index) {
                                  final niche = filteredNiches[index];
                                  final isSelected =
                                      niche.matches(currentNiche);

                                  return Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        setState(() {
                                          _nicheController.text = niche.title;
                                        });
                                        Navigator.of(sheetContext).pop();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? CC.primary.withValues(
                                                  alpha: CC.isDark
                                                      ? 0.18
                                                      : 0.08)
                                              : CC.background,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? CC.primary
                                                : CC.stroke.withValues(
                                                    alpha: CC.isDark
                                                        ? 0.35
                                                        : 0.6),
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                niche.title,
                                                style: TS.bodyMedium(
                                                  color: isSelected
                                                      ? CC.primary
                                                      : CC.textPrimary,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                ).copyWith(fontSize: 14),
                                              ),
                                            ),
                                            8.width,
                                            Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? CC.primary
                                                    : Colors.transparent,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? CC.primary
                                                      : CC.stroke,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check_rounded,
                                                      size: 14,
                                                      color: CC.whiteText,
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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

    try {
      final authRepo = Get.isRegistered<AuthRepository>()
          ? Get.find<AuthRepository>()
          : Get.put<AuthRepository>(ApiAuthRepository());

      final response = await authRepo.updateCreatorProfile(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        niche: _nicheController.text.trim(),
        audienceDescription: _audienceController.text.trim(),
        goals: _goalsController.text.trim(),
      );

      setState(() => _isSaving = false);

      if (response.isSuccess) {
        if (!mounted) return;
        Navigator.of(context).pop(true);
        AppToast.success("Your creator profile has been updated successfully.");
      } else {
        AppToast.error(response.message.isNotEmpty ? response.message : "Failed to update profile");
      }
    } catch (e) {
      setState(() => _isSaving = false);
      AppToast.error("An error occurred: $e");
    }
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
                      label: "Display Name",
                      controller: _nameController,
                      hint: "Enter your display name",
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Name is required" : null,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}), // refresh initials avatar
                    ),
                    14.height,
                    _buildNonEditableField(
                      label: "Email Address",
                      value: _emailController.text.isNotEmpty
                          ? _emailController.text
                          : (ApiService.currentUser?.email.isNotEmpty == true
                              ? ApiService.currentUser!.email
                              : (ApiService.userEmail ?? "")),
                      hint: "Enter your email address",
                      suffixIcon: Icon(
                        Icons.lock_rounded,
                        size: 16,
                        color: CC.grey.withValues(alpha: 0.8),
                      ),
                    ),
                    24.height,

                    // ── Creator Strategy & Audience ─────────────────────────
                    Text(
                      "Creator Strategy & Audience",
                      style: TS.sectionTitle(
                        color: CC.textPrimary,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 15),
                    ),
                    14.height,
                    _buildSelectableField(
                      label: "Content Niche",
                      value: _nicheController.text,
                      hint: "Select your content niche",
                      onTap: _showNichePickerSheet,
                    ),
                    14.height,
                    _buildTextField(
                      label: "Target Audience",
                      controller: _audienceController,
                      hint: "e.g. Early adopters & AI builders",
                      textInputAction: TextInputAction.next,
                    ),
                    14.height,
                    _buildTextField(
                      label: "Creator Goals",
                      controller: _goalsController,
                      hint: "e.g. GROWTH, MONETIZATION",
                      textInputAction: TextInputAction.done,
                    ),
                    24.height,

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

  // ── Selectable Field Builder ─────────────────────────────────────────────
  Widget _buildSelectableField({
    required String label,
    required String value,
    required String hint,
    required VoidCallback onTap,
  }) {
    final hasValue = value.trim().isNotEmpty;

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
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: CC.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CC.stroke,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? value : hint,
                      style: TS.bodyMedium(
                        color: hasValue
                            ? CC.textPrimary
                            : CC.grey.withValues(alpha: 0.7),
                        fontWeight:
                            hasValue ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: CC.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Non-Editable Field Builder ───────────────────────────────────────────
  Widget _buildNonEditableField({
    required String label,
    required String value,
    required String hint,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TS.caption(
                color: CC.textSecondary,
                fontWeight: FontWeight.w500,
              ).copyWith(fontSize: 13),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, size: 12, color: CC.textSecondary.withValues(alpha: 0.7)),
                4.width,
                Text(
                  "Non-editable",
                  style: TS.caption(
                    color: CC.textSecondary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ).copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        6.height,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: CC.surface.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CC.stroke.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.isNotEmpty ? value : hint,
                  style: TS.bodyMedium(
                    color: value.isNotEmpty ? CC.textSecondary : CC.grey.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (suffixIcon != null) suffixIcon,
            ],
          ),
        ),
      ],
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
