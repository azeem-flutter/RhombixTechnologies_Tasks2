import 'dart:convert';

import 'package:arthub/app/controllers/profile_controller.dart';
import 'package:arthub/app/repositories/artwork_repository.dart';
import 'package:arthub/app/services/cloudinary_configure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../models/artwork_model.dart';
import '../services/error_service.dart';

class ArtworkController extends GetxController {
  final FirestoreArtworkRepository _repository = FirestoreArtworkRepository();

  final artworks = <ArtworkModel>[].obs;
  final filteredArtworks = <ArtworkModel>[].obs;
  final isLoading = false.obs;

  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;

  final selectedImage = Rx<XFile?>(null);
  final selectedCategoryUpload = RxnString(); // nullable string

  final isUploading = false.obs;

  final ImagePicker _picker = ImagePicker();

  final selectedArtworkId = ''.obs;

  void selectArtwork(String artworkId) {
    selectedArtworkId.value = artworkId;
  }

  ArtworkModel? get selectedArtwork {
    try {
      return artworks.firstWhere((art) => art.id == selectedArtworkId.value);
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchArtworks();
  }

  Future<void> pickImage() async {
    selectedImage.value = await _picker.pickImage(source: ImageSource.gallery);
  }

  Future<String> _uploadImageToCloudinary(XFile image) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.arthubartwork
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body);

    if (response.statusCode != 200) {
      throw Exception(data['error']['message']);
    }

    return data['secure_url'];
  }

  Future<void> submitArtworkUpload({
    required String title,
    required String description,
  }) async {
    if (selectedImage.value == null) {
      ErrorService.showError('Please select an image');
      return;
    }

    if (selectedCategoryUpload.value == null) {
      ErrorService.showError('Please select a category');
      return;
    }

    try {
      isUploading.value = true;

      final user = ProfileController.instance.user;
      final docRef = FirebaseFirestore.instance.collection('artworks').doc();

      // 🔥 Upload image to Cloudinary
      final imageUrl = await _uploadImageToCloudinary(selectedImage.value!);

      final artwork = ArtworkModel(
        id: docRef.id,
        title: title.trim(),
        description: description.trim(),
        imageUrl: imageUrl,
        category: selectedCategoryUpload.string,
        artistId: user!.id,
        artistName: user.name,
        artistImage: user.profileImage,
        createdAt: Timestamp.now(),
      );

      await _repository.uploadArtwork(artwork);
      await fetchArtworks();

      selectedImage.value = null;

      Get.back();
      ErrorService.showSuccess('Artwork uploaded');
    } catch (e) {
      ErrorService.handleError(e);
    } finally {
      isUploading.value = false;
    }
  }

  void removeSelectedImage() {
    selectedImage.value = null;
  }

  Future<void> fetchArtworks() async {
    try {
      isLoading.value = true;
      artworks.value = await _repository.fetchArtworks();
      _applyFilters();
    } catch (e) {
      ErrorService.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void searchArtworks(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    filteredArtworks.value = artworks.where((artwork) {
      final categoryMatch =
          selectedCategory.value == 'All' ||
          artwork.category == selectedCategory.value;

      final searchMatch =
          searchQuery.value.isEmpty ||
          artwork.title.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          artwork.artistName.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );

      return categoryMatch && searchMatch;
    }).toList();
  }

  /// Toggle like for an artwork. NO optimistic UI updates.
  /// UI will update when Firestore stream reflects the change.
  Future<void> toggleLike(String artworkId, String userId) async {
    try {
      await _repository.toggleLike(artworkId, userId);
      // UI updates automatically via streams in the view layer
    } catch (e) {
      ErrorService.handleError(e);
    }
  }

  /// Increment view count (idempotent per user per artwork).
  /// Only call once when the details screen opens, not on every build().
  Future<void> incrementViewOnce(String artworkId, String userId) async {
    try {
      await _repository.incrementViewOnce(artworkId, userId);
    } catch (e) {
      print('Error incrementing view: $e');
      // Non-critical; don't show error to user
    }
  }

  /// Get stream of like count for an artwork
  Stream<int> getLikeCountStream(String artworkId) {
    return _repository.getLikeCountStream(artworkId);
  }

  /// Get stream of view count for an artwork
  Stream<int> getViewCountStream(String artworkId) {
    return _repository.getViewCountStream(artworkId);
  }

  /// Get stream of whether current user has liked this artwork
  Stream<bool> isLikedStream(String artworkId, String userId) {
    return _repository.isLikedStream(artworkId, userId);
  }
}
