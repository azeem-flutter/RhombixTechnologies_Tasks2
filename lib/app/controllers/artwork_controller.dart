import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artwork_model.dart';
import '../utils/constants.dart';

class ArtworkController extends GetxController {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<ArtworkModel> artworks = <ArtworkModel>[].obs;
  final RxList<ArtworkModel> filteredArtworks = <ArtworkModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final Rx<ArtworkModel?> selectedArtwork = Rx<ArtworkModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchArtworks();
  }

  // Fetch all artworks from Firestore
  // Use ArtworkController to fetch artworks from Firestore
  Future<void> fetchArtworks() async {
    try {
      isLoading.value = true;

      // TODO: Fetch from Firestore
      // QuerySnapshot snapshot = await _firestore
      //     .collection('artworks')
      //     .orderBy('createdAt', descending: true)
      //     .get();
      //
      // artworks.value = snapshot.docs
      //     .map((doc) => ArtworkModel.fromMap(doc.data() as Map<String, dynamic>))
      //     .toList();

      // Demo data
      artworks.value = _getDummyArtworks();
      filteredArtworks.value = artworks;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch artworks');
    } finally {
      isLoading.value = false;
    }
  }

  // Filter artworks by category
  void filterByCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  // Search artworks
  void searchArtworks(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  // Apply filters (category + search)
  void _applyFilters() {
    filteredArtworks.value = artworks.where((artwork) {
      bool matchesCategory =
          selectedCategory.value == 'All' ||
          artwork.category == selectedCategory.value;
      bool matchesSearch =
          searchQuery.value.isEmpty ||
          artwork.title.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          artwork.artistName.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Like/Unlike artwork
  // Firestore: Increment likes count and add userId to likedBy array
  Future<void> toggleLike(String artworkId, String userId) async {
    try {
      final index = artworks.indexWhere((a) => a.id == artworkId);
      if (index == -1) return;

      final artwork = artworks[index];
      final isLiked = artwork.likedBy.contains(userId);

      // TODO: Update Firestore
      // if (isLiked) {
      //   await _firestore.collection('artworks').doc(artworkId).update({
      //     'likes': FieldValue.increment(-1),
      //     'likedBy': FieldValue.arrayRemove([userId]),
      //   });
      // } else {
      //   await _firestore.collection('artworks').doc(artworkId).update({
      //     'likes': FieldValue.increment(1),
      //     'likedBy': FieldValue.arrayUnion([userId]),
      //   });
      // }

      // Update local state
      final updatedLikedBy = List<String>.from(artwork.likedBy);
      if (isLiked) {
        updatedLikedBy.remove(userId);
        artworks[index] = artwork.copyWith(
          likes: artwork.likes - 1,
          likedBy: updatedLikedBy,
        );
      } else {
        updatedLikedBy.add(userId);
        artworks[index] = artwork.copyWith(
          likes: artwork.likes + 1,
          likedBy: updatedLikedBy,
        );
      }

      artworks.refresh();
      _applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update like');
    }
  }

  // Get artwork by ID
  void selectArtwork(String artworkId) {
    selectedArtwork.value = artworks.firstWhereOrNull((a) => a.id == artworkId);
  }

  // Increment view count
  // Firestore: Increment views count
  Future<void> incrementViews(String artworkId) async {
    // TODO: Update in Firestore
    // await _firestore.collection('artworks').doc(artworkId).update({
    //   'views': FieldValue.increment(1),
    // });
  }

  // Dummy data for demo
  List<ArtworkModel> _getDummyArtworks() {
    return [
      ArtworkModel(
        id: '1',
        title: 'Neon Dreams',
        imageUrl:
            'https://images.unsplash.com/photo-1549887534-1541e9326642?w=800',
        description:
            'A cyberpunk-inspired digital artwork featuring neon lights and futuristic architecture.',
        category: 'Digital Art',
        artistId: 'artist1',
        artistName: 'Sarah Chen',
        likes: 234,
        likedBy: [],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        views: 1240,
      ),
      ArtworkModel(
        id: '2',
        title: 'Mountain Serenity',
        imageUrl:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        description:
            'Breathtaking landscape photography capturing the beauty of mountain ranges at sunset.',
        category: 'Photography',
        artistId: 'artist2',
        artistName: 'Alex Rivera',
        likes: 567,
        likedBy: [],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        views: 2341,
      ),
      ArtworkModel(
        id: '3',
        title: 'Abstract Emotions',
        imageUrl:
            'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800',
        description:
            'An exploration of color and form through abstract expressionism.',
        category: 'Abstract',
        artistId: 'artist3',
        artistName: 'Maya Patel',
        likes: 189,
        likedBy: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        views: 876,
      ),
      ArtworkModel(
        id: '4',
        title: 'Character Study #12',
        imageUrl:
            'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=800',
        description: 'Original character design for fantasy RPG project.',
        category: 'Character Design',
        artistId: 'artist4',
        artistName: 'Jordan Lee',
        likes: 432,
        likedBy: [],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        views: 1567,
      ),
      ArtworkModel(
        id: '5',
        title: 'Urban Jungle',
        imageUrl:
            'https://images.unsplash.com/photo-1499781350541-7783f6c6a0c8?w=800',
        description: 'Street photography capturing the essence of city life.',
        category: 'Photography',
        artistId: 'artist5',
        artistName: 'Emma Watson',
        likes: 321,
        likedBy: [],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        views: 1893,
      ),
      ArtworkModel(
        id: '6',
        title: 'Geometric Harmony',
        imageUrl:
            'https://images.unsplash.com/photo-1557672172-298e090bd0f1?w=800',
        description: 'Minimalist geometric patterns in vibrant colors.',
        category: 'Abstract',
        artistId: 'artist6',
        artistName: 'Lucas Kim',
        likes: 278,
        likedBy: [],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        views: 1234,
      ),
    ];
  }
}
