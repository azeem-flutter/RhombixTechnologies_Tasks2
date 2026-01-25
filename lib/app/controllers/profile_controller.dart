import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/artwork_model.dart';

class ProfileController extends GetxController {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxList<ArtworkModel> userArtworks = <ArtworkModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  // Load user profile
  // Firestore: Fetch user document by userId
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;

      // TODO: Fetch from Firestore
      // String userId = FirebaseAuth.instance.currentUser!.uid;
      // DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      // user.value = UserModel.fromMap(doc.data() as Map<String, dynamic>);

      // Demo data
      user.value = UserModel(
        id: 'demo_user',
        name: 'John Doe',
        email: 'john@arthub.com',
        bio: 'Digital artist & designer',
        profileImage:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        favorites: ['1', '3', '5'],
      );

      nameController.text = user.value?.name ?? '';
      bioController.text = user.value?.bio ?? '';

      await fetchUserArtworks();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch artworks uploaded by user
  // Firestore: Query artworks where artistId equals current userId
  Future<void> fetchUserArtworks() async {
    try {
      // TODO: Fetch from Firestore
      // String userId = user.value?.id ?? '';
      // QuerySnapshot snapshot = await _firestore
      //     .collection('artworks')
      //     .where('artistId', isEqualTo: userId)
      //     .orderBy('createdAt', descending: true)
      //     .get();
      //
      // userArtworks.value = snapshot.docs
      //     .map((doc) => ArtworkModel.fromMap(doc.data() as Map<String, dynamic>))
      //     .toList();

      // Demo: Filter artworks for this user
      userArtworks.value = [
        ArtworkModel(
          id: '101',
          title: 'My First Digital Painting',
          imageUrl:
              'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=800',
          description: 'Experimenting with digital brushes',
          category: 'Digital Art',
          artistId: 'demo_user',
          artistName: 'John Doe',
          likes: 45,
          likedBy: [],
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          views: 234,
        ),
      ];
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch artworks');
    }
  }

  // Update profile info
  // Firestore: Update user document fields (name, bio, profileImage)
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      // TODO: Update in Firestore
      // String userId = user.value?.id ?? '';
      // await _firestore.collection('users').doc(userId).update({
      //   'name': nameController.text.trim(),
      //   'bio': bioController.text.trim(),
      // });

      user.value = user.value?.copyWith(
        name: nameController.text.trim(),
        bio: bioController.text.trim(),
      );

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      isLoading.value = false;
    }
  }

  // Pick and upload profile image
  // Firebase Storage: Upload image file and get download URL
  Future<void> updateProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      isUploading.value = true;

      // TODO: Upload to Firebase Storage
      // String userId = user.value?.id ?? '';
      // String fileName = 'profile_$userId.jpg';
      // Reference ref = _storage.ref().child('profiles/$fileName');
      // await ref.putFile(File(image.path));
      // String imageUrl = await ref.getDownloadURL();
      //
      // await _firestore.collection('users').doc(userId).update({
      //   'profileImage': imageUrl,
      // });

      // Demo: Use picked image path
      user.value = user.value?.copyWith(profileImage: image.path);

      Get.snackbar(
        'Success',
        'Profile image updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image');
    } finally {
      isUploading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
