import 'package:arthub/app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'dart:io';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  XFile? _selectedImage;
  String _selectedCategory = AppConstants.categories[1];
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _uploadArtwork() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      Get.snackbar('Error', 'Please select an image');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Firebase Storage: Upload image first
    // final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    // final ref = FirebaseStorage.instance.ref().child('artworks/$fileName');
    // await ref.putFile(File(_selectedImage!.path));
    // final imageUrl = await ref.getDownloadURL();

    // Firestore: Save artwork metadata
    // final artwork = ArtworkModel(
    //   id: FirebaseFirestore.instance.collection('artworks').doc().id,
    //   title: _titleController.text.trim(),
    //   description: _descriptionController.text.trim(),
    //   imageUrl: imageUrl,
    //   category: _selectedCategory,
    //   artistId: currentUser.id,
    //   artistName: currentUser.name,
    //   createdAt: DateTime.now(),
    // );
    // await FirebaseFirestore.instance.collection('artworks').doc(artwork.id).set(artwork.toMap());

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isUploading = false;
    });

    Get.snackbar(
      'Success',
      'Artwork uploaded successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    Get.back();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Artwork')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardBackgroundDark
                        : AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 60,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to select image',
                              style: AppTextStyles.body.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              CustomTextField(
                label: 'Title',
                hint: 'Give your artwork a title',
                controller: _titleController,
                validator: Validators.validateTitle,
                maxLength: AppConstants.maxTitleLength,
              ),
              const SizedBox(height: 20),

              // Description
              CustomTextField(
                label: 'Description',
                hint: 'Describe your artwork',
                controller: _descriptionController,
                validator: Validators.validateDescription,
                maxLines: 5,
                maxLength: AppConstants.maxDescriptionLength,
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              Text(
                'Category',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(),
                items: AppConstants.categories
                    .where((c) => c != 'All')
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              // Upload Button
              CustomButton(
                text: 'Upload Artwork',
                onPressed: _uploadArtwork,
                width: double.infinity,
                isLoading: _isUploading,
                icon: Icons.cloud_upload,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
