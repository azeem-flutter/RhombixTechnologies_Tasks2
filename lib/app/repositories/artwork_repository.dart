import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artwork_model.dart';
import '../models/user_model.dart';

class FirestoreArtworkRepository {
  final _artworks = FirebaseFirestore.instance.collection('artworks');

  /// Fetch all artworks in descending creation order
  Future<List<ArtworkModel>> fetchArtworks() async {
    final snapshot = await _artworks
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ArtworkModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Fetch a single artwork by ID
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

  /// Upload a new artwork
  Future<void> uploadArtwork(ArtworkModel artwork) async {
    await _artworks.doc(artwork.id).set(artwork.toMap());
  }

  /// Toggle like by creating/deleting likes/{userId} doc only.
  /// NO writes to artwork fields like likesCount.
  /// Counts are derived from subcollection snapshot instead.
  Future<void> toggleLike(String artworkId, String userId) async {
    final likeRef = _artworks.doc(artworkId).collection('likes').doc(userId);

    // Check if already liked and toggle
    final snap = await likeRef.get();
    if (snap.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({'at': Timestamp.now()});
    }
  }

  /// Create a view doc for this user on this artwork (idempotent).
  /// Only called once per session when opening details screen.
  /// Counts are derived from subcollection snapshot.
  Future<void> incrementViewOnce(String artworkId, String userId) async {
    final viewRef = _artworks.doc(artworkId).collection('views').doc(userId);

    // Idempotent: only create if doesn't exist
    final snap = await viewRef.get();
    if (!snap.exists) {
      await viewRef.set({'at': Timestamp.now()});
    }
  }

  /// Check if a user has liked an artwork
  Future<bool> isLiked(String artworkId, String userId) async {
    final likeRef = _artworks.doc(artworkId).collection('likes').doc(userId);
    final snap = await likeRef.get();
    return snap.exists;
  }

  /// Stream of like count for an artwork (count of docs in likes subcollection)
  Stream<int> getLikeCountStream(String artworkId) {
    return _artworks
        .doc(artworkId)
        .collection('likes')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Stream of view count for an artwork (count of docs in views subcollection)
  Stream<int> getViewCountStream(String artworkId) {
    return _artworks
        .doc(artworkId)
        .collection('views')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Stream of whether current user has liked this artwork
  Stream<bool> isLikedStream(String artworkId, String userId) {
    return _artworks
        .doc(artworkId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((snap) => snap.exists);
  }
}
