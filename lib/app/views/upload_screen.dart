import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/artwork_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class UploadScreen extends StatelessWidget {
  UploadScreen({super.key});

  final ArtworkController controller = Get.find<ArtworkController>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Upload Artwork',
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.backgroundDark,
                        const Color(0xFF2D1B36),
                        AppColors.cardBackgroundDark,
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.1),
                        Colors.white,
                        const Color(0xFFF5F0FF),
                      ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// IMAGE PICKER
                    GestureDetector(
                      onTap: controller.pickImage,
                      child: Obx(() {
                        final image = controller.selectedImage.value;

                        return Container(
                          height: 320,
                          width: double.infinity,
                          decoration: _imageBoxDecoration(isDark),
                          child: image == null
                              ? _emptyImageUI(isDark)
                              : _selectedImageUI(image),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    /// FORM
                    _formCard(isDark),

                    const SizedBox(height: 32),

                    /// UPLOAD BUTTON
                    Obx(
                      () => CustomButton(
                        text: 'Upload Artwork',
                        width: double.infinity,
                        isLoading: controller.isUploading.value,
                        icon: Icons.cloud_upload_rounded,
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;

                          controller.submitArtworkUpload(
                            title: titleController.text,
                            description: descriptionController.text,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI PARTS =================

  BoxDecoration _imageBoxDecoration(bool isDark) => BoxDecoration(
    color: isDark ? AppColors.cardBackgroundDark : Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: isDark
          ? AppColors.primaryDark.withValues(alpha: 0.5)
          : AppColors.primary.withValues(alpha: 0.5),
      width: 2,
    ),
  );

  Widget _emptyImageUI(bool isDark) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.add_photo_alternate_rounded,
        size: 56,
        color: isDark ? AppColors.primaryDark : AppColors.primary,
      ),
      const SizedBox(height: 16),
      Text(
        'Upload Artwork Image',
        style: AppTextStyles.heading3.copyWith(fontSize: 20),
      ),
      const SizedBox(height: 8),
      Text('Tap to browse gallery', style: AppTextStyles.bodySmall),
    ],
  );

  Widget _selectedImageUI(XFile image) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: Stack(
      children: [
        Positioned.fill(child: Image.file(File(image.path), fit: BoxFit.cover)),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: Get.find<ArtworkController>().removeSelectedImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _formCard(bool isDark) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: isDark
          ? AppColors.cardBackgroundDark.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        CustomTextField(
          label: 'Title',
          hint: 'Give your artwork a title',
          controller: titleController,
          validator: Validators.validateTitle,
          maxLength: AppConstants.maxTitleLength,
        ),
        const SizedBox(height: 24),
        CustomTextField(
          label: 'Description',
          hint: 'Describe your artwork',
          controller: descriptionController,
          validator: Validators.validateDescription,
          maxLines: 5,
          maxLength: AppConstants.maxDescriptionLength,
        ),
        const SizedBox(height: 24),
        _categoryDropdown(isDark),
      ],
    ),
  );

  Widget _categoryDropdown(bool isDark) {
    final controller = Get.find<ArtworkController>();

    return Obx(
      () => DropdownButtonFormField<String>(
        initialValue:
            controller.selectedCategoryUpload.value?.isNotEmpty == true
            ? controller.selectedCategoryUpload.value
            : null, // safe null handling
        decoration: const InputDecoration(border: InputBorder.none),
        dropdownColor: isDark ? AppColors.cardBackgroundDark : Colors.white,
        items: AppConstants.categories
            .where((c) => c != 'All')
            .map(
              (category) =>
                  DropdownMenuItem(value: category, child: Text(category)),
            )
            .toList(),
        onChanged: (value) {
          controller.selectedCategoryUpload.value = value!;
        },
        hint: const Text('Select a category'), // shows placeholder
      ),
    );
  }
}
