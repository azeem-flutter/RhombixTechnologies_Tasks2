import 'dart:convert';
import 'dart:io';

import 'package:arthub/app/controllers/auth_controller.dart';
import 'package:arthub/app/models/artwork_model.dart';
import 'package:arthub/app/models/user_model.dart';
import 'package:arthub/app/services/cloudinary_configure.dart';
import 'package:arthub/app/services/error_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final AuthController authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // =============================
  // STATE
  // =============================
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  final RxInt artworksCount = 0.obs;
  final RxInt favoritesCount = 0.obs;
  final RxInt totalViewsCount = 0.obs;

  final RxList<ArtworkModel> userArtworks = <ArtworkModel>[].obs;

  final nameController = TextEditingController();
  final bioController = TextEditingController();

  UserModel? get _currentUser => authController.currentUser.value;
  UserModel? get user => _currentUser;

  // =============================
  // LIFECYCLE
  // =============================
  @override
  void onInit() {
    super.onInit();
    debugPrint('🔥 ProfileController INIT');
  }

  @override
  void onReady() {
    super.onReady();

    // Handle already-logged-in user
    final user = authController.currentUser.value;
    if (user != null) {
      _syncProfileFields(user);
      _bindUserArtworks(user.id);
      _bindUserFavorites(user.id);
      _bindTotalViews(user.id);
    }

    // React to auth changes
    ever<UserModel?>(authController.currentUser, (user) {
      if (user == null) return;

      _syncProfileFields(user);
      _bindUserArtworks(user.id);
      _bindUserFavorites(user.id);
      _bindTotalViews(user.id);
    });
  }

  // =============================
  // PROFILE SYNC
  // =============================
  void _syncProfileFields(UserModel user) {
    nameController.text = user.name;
    bioController.text = user.bio ?? '';
  }

  // =============================
  // REAL-TIME ARTWORKS (FIXED)
  // =============================
  void _bindUserArtworks(String userId) {
    userArtworks.bindStream(
      _firestore
          .collection('artworks')
          .where('artistId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            final list = snapshot.docs
                .map((doc) => ArtworkModel.fromMap(doc.id, doc.data()))
                .toList();

            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            artworksCount.value = list.length;

            return list;
          }),
    );
  }

  // =============================
  // FAVORITES: ARTWORKS LIKED BY CURRENT USER
  // =============================
  /// Bind real-time stream of artworks that the current user has liked.
  /// Uses collectionGroup('likes') to find all like docs by this user,
  /// then resolves the artwork documents.
  void _bindUserFavorites(String userId) {
    _firestore
        .collection('artworks')
        .where('artistId', isEqualTo: userId)
        .snapshots()
        .asyncMap((artworksSnap) async {
          if (artworksSnap.docs.isEmpty) {
            favoritesCount.value = 0;
            return 0;
          }

          int totalLikes = 0;

          for (final artworkDoc in artworksSnap.docs) {
            final likeCountSnap = await artworkDoc.reference
                .collection('likes')
                .count()
                .get();

            totalLikes += likeCountSnap.count ?? 0;
          }

          favoritesCount.value = totalLikes;
          return totalLikes;
        })
        .listen((_) {});
  }

  // =============================
  // TOTAL VIEWS: SUM OF ALL VIEWS ON USER'S ARTWORKS
  // =============================
  /// Bind real-time stream to calculate total views across all artworks
  /// created by the current user.
  void _bindTotalViews(String userId) {
    _firestore
        .collection('artworks')
        .where('artistId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) {
            totalViewsCount.value = 0;
            return 0;
          }

          int totalViews = 0;

          // For each artwork, count the views subcollection
          for (final artworkDoc in snapshot.docs) {
            final viewsSnapshot = await artworkDoc.reference
                .collection('views')
                .count()
                .get();
            totalViews += viewsSnapshot.count ?? 0;
          }

          totalViewsCount.value = totalViews;
          return totalViews;
        })
        .listen((_) {}); // Listen and update count
  }

  // =============================
  // UPDATE PROFILE
  // =============================
  Future<void> updateProfile() async {
    final currentUser = _currentUser;
    if (currentUser == null) return;

    try {
      isLoading.value = true;

      final updatedName = nameController.text.trim();
      final updatedBio = bioController.text.trim();

      await _firestore.collection('users').doc(currentUser.id).update({
        'name': updatedName,
        'bio': updatedBio,
      });

      authController.currentUser.value = currentUser.copyWith(
        name: updatedName,
        bio: updatedBio,
      );

      ErrorService.showSuccess('Profile updated');
    } catch (e) {
      ErrorService.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // =============================
  // UPDATE PROFILE IMAGE
  // =============================
  Future<void> updateProfileImage() async {
    final currentUser = _currentUser;
    if (currentUser == null) return;

    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );

    if (image == null) return;

    try {
      isUploading.value = true;

      final imageUrl = await _uploadToCloudinary(File(image.path));

      await _firestore.collection('users').doc(currentUser.id).update({
        'profileImage': imageUrl,
      });

      authController.currentUser.value = currentUser.copyWith(
        profileImage: imageUrl,
      );

      ErrorService.showSuccess('Profile image updated');
    } catch (e) {
      ErrorService.handleError(e);
    } finally {
      isUploading.value = false;
    }
  }

  // =============================
  // CLOUDINARY
  // =============================
  Future<String> _uploadToCloudinary(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body);

    if (response.statusCode != 200) {
      throw Exception(data['error']['message']);
    }

    return data['secure_url'];
  }

  // =============================
  // CLEANUP
  // =============================
  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
