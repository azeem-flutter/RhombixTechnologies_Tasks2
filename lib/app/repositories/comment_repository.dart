import 'package:arthub/app/models/comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CREATE
  Future<void> addComment(CommentModel comment) async {
    await _db
        .collection('artworks')
        .doc(comment.artworkId)
        .collection('comments')
        .doc(comment.id)
        .set(comment.toMap());
  }

  // READ
  Future<List<CommentModel>> fetchComments(String artworkId) async {
    final snapshot = await _db
        .collection('artworks')
        .doc(artworkId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => CommentModel.fromDoc(doc)).toList();
  }

  // DELETE
  Future<void> deleteComment({
    required String artworkId,
    required String commentId,
  }) async {
    await _db
        .collection('artworks')
        .doc(artworkId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }
}
