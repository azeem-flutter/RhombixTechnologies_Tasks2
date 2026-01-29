# Detailed Code Changes

## 1. ArtworkController Changes

### File: lib/app/controllers/artwork_controller.dart

#### Added Method:
```dart
/// Refresh a single artwork from Firestore to get latest data (views, likes, etc)
Future<void> refreshArtwork(String artworkId) async {
  try {
    final artwork = await _repository.fetchArtworkById(artworkId);
    if (artwork != null) {
      final index = artworks.indexWhere((a) => a.id == artworkId);
      if (index != -1) {
        artworks[index] = artwork;
        _applyFilters();
      }
    }
  } catch (e) {
    ErrorService.handleError(e);
  }
}
```

#### Modified Method:
```dart
// OLD:
Future<void> incrementViewOnce(String artworkId, String userId) async {
  await _repository.incrementViewOnce(artworkId, userId);
}

// NEW:
Future<void> incrementViewOnce(String artworkId, String userId) async {
  await _repository.incrementViewOnce(artworkId, userId);
  // Refresh the artwork to update view count in UI
  await refreshArtwork(artworkId);
}
```

---

## 2. ArtworkRepository Changes

### File: lib/app/repositories/artwork_repository.dart

#### Added Imports:
```dart
import '../models/user_model.dart';
```

#### Added Methods:
```dart
/// Fetch a single artwork by ID from Firestore
Future<ArtworkModel?> fetchArtworkById(String artworkId) async {
  try {
    final doc = await _artworks.doc(artworkId).get();
    if (doc.exists) {
      return ArtworkModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  } catch (e) {
    print('Error fetching artwork: $e');
    return null;
  }
}

/// Fetch user data by ID to get latest profile image
Future<UserModel?> fetchUserById(String userId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  } catch (e) {
    print('Error fetching user: $e');
    return null;
  }
}
```

---

## 3. ArtworkCard Changes

### File: lib/app/widgets/artwork_card.dart

#### Imports Change:
```dart
// ADDED:
import 'package:get/get.dart';
import '../repositories/artwork_repository.dart';

// OLD:
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/artwork_model.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

// NEW:
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../models/artwork_model.dart';
import '../repositories/artwork_repository.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
```

#### Class Change:
```dart
// OLD:
class ArtworkCard extends StatelessWidget {
  final ArtworkModel artwork;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const ArtworkCard({
    super.key,
    required this.artwork,
    this.onTap,
    this.onLike,
    this.isLiked = false,
  });

// NEW:
class ArtworkCard extends StatefulWidget {
  final ArtworkModel artwork;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const ArtworkCard({
    super.key,
    required this.artwork,
    this.onTap,
    this.onLike,
    this.isLiked = false,
  });

  @override
  State<ArtworkCard> createState() => _ArtworkCardState();
}

class _ArtworkCardState extends State<ArtworkCard> {
  late String _artistImage;
  final FirestoreArtworkRepository _repository = FirestoreArtworkRepository();

  @override
  void initState() {
    super.initState();
    _artistImage = widget.artwork.artistImage ?? '';
    _loadLatestArtistImage();
  }

  /// Fetch the latest artist profile image from Firestore
  Future<void> _loadLatestArtistImage() async {
    try {
      final user = await _repository.fetchUserById(widget.artwork.artistId);
      if (user != null && user.profileImage != null && mounted) {
        setState(() {
          _artistImage = user.profileImage!;
        });
      }
    } catch (e) {
      print('Error loading artist image: $e');
    }
  }
```

#### Widget References Update:
All references to `artwork` → `widget.artwork`
All references to `onTap` → `widget.onTap`
All references to `onLike` → `widget.onLike`
All references to `isLiked` → `widget.isLiked`

All references to `artwork.artistImage` → `_artistImage`

---

## 4. ArtworkDetailsScreen Changes

### File: lib/app/views/artwork_details_screen.dart

#### Added Import:
```dart
import '../repositories/artwork_repository.dart';
```

#### State Class Addition:
```dart
class _ArtworkDetailsScreenState extends State<ArtworkDetailsScreen> {
  late String _artistImage = '';
  final FirestoreArtworkRepository _repository = FirestoreArtworkRepository();

  @override
  void initState() {
    super.initState();
    // Fetch comments and increment views when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final artworkController = Get.find<ArtworkController>();
      final commentsController = Get.find<CommentsController>();
      final artwork = artworkController.selectedArtwork;
      final user = ProfileController.instance.user;
      if (artwork != null) {
        _artistImage = artwork.artistImage ?? '';
        _loadLatestArtistImage(artwork.artistId);
        commentsController.fetchComments(artwork.id);
        artworkController.incrementViewOnce(artwork.id, user!.id);
      }
    });
  }

  /// Fetch the latest artist profile image from Firestore
  Future<void> _loadLatestArtistImage(String artistId) async {
    try {
      final user = await _repository.fetchUserById(artistId);
      if (user != null && user.profileImage != null && mounted) {
        setState(() {
          _artistImage = user.profileImage!;
        });
      }
    } catch (e) {
      print('Error loading artist image: $e');
    }
  }
```

#### ProfileAvatar Update:
```dart
// OLD:
ProfileAvatar(
  imageUrl: artwork.artistImage,
  size: 50,
  initials: artwork.artistName[0],
),

// NEW:
ProfileAvatar(
  imageUrl: _artistImage.isNotEmpty ? _artistImage : artwork.artistImage,
  size: 50,
  initials: artwork.artistName[0],
),
```

---

## 5. ProfileController Changes

### File: lib/app/controllers/profile_controller.dart

#### Updated Method:
```dart
// OLD updateProfileImage():
Future<void> updateProfileImage() async {
  try {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );

    if (image == null) return;

    isUploading.value = true;

    final imageUrl = await _uploadToCloudinary(File(image.path));

    final uid = user!.id;

    await _firestore.collection('users').doc(uid).update({
      'profileImage': imageUrl,
    });

    authController.currentUser.value = user!.copyWith(profileImage: imageUrl);

    ErrorService.showSuccess('Profile image updated');
  } catch (e) {
    ErrorService.handleError(e);
  } finally {
    isUploading.value = false;
  }
}

// NEW updateProfileImage():
Future<void> updateProfileImage() async {
  try {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );

    if (image == null) return;

    isUploading.value = true;

    final imageUrl = await _uploadToCloudinary(File(image.path));

    final uid = user!.id;

    // Update user profile image in Firestore
    await _firestore.collection('users').doc(uid).update({
      'profileImage': imageUrl,
    });

    // Update local auth controller
    authController.currentUser.value = user!.copyWith(profileImage: imageUrl);

    // Update all artworks by this user with new profile image
    for (var artwork in userArtworks) {
      await _firestore.collection('artworks').doc(artwork.id).update({
        'artistImage': imageUrl,
      });
    }

    ErrorService.showSuccess('Profile image updated');
  } catch (e) {
    ErrorService.handleError(e);
  } finally {
    isUploading.value = false;
  }
}
```

---

## Summary of Key Changes

| Issue | Solution |
|-------|----------|
| View count not updating | Added `refreshArtwork()` to fetch latest data after increment |
| Profile image not syncing | Dynamic loading + batch update of all user artworks |
| Stats not displaying | Already working, verified implementation |

All changes maintain backward compatibility and follow the existing code patterns in the project.
