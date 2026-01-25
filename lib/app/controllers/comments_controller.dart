import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentsController extends GetxController {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxBool isLoading = false.obs;
  final TextEditingController commentController = TextEditingController();

  // Fetch comments for an artwork
  // Firestore: Query comments subcollection under artwork document
  Future<void> fetchComments(String artworkId) async {
    try {
      isLoading.value = true;

      // TODO: Fetch from Firestore
      // QuerySnapshot snapshot = await _firestore
      //     .collection('artworks')
      //     .doc(artworkId)
      //     .collection('comments')
      //     .orderBy('timestamp', descending: true)
      //     .get();
      //
      // comments.value = snapshot.docs
      //     .map((doc) => CommentModel.fromMap(doc.data() as Map<String, dynamic>))
      //     .toList();

      // Demo data
      comments.value = _getDummyComments(artworkId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load comments');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new comment
  // Firestore: Add comment document to comments subcollection
  Future<void> addComment(
    String artworkId,
    String userId,
    String userName,
  ) async {
    if (commentController.text.trim().isEmpty) return;

    try {
      // TODO: Add to Firestore
      // final commentRef = _firestore
      //     .collection('artworks')
      //     .doc(artworkId)
      //     .collection('comments')
      //     .doc();
      //
      // final comment = CommentModel(
      //   id: commentRef.id,
      //   artworkId: artworkId,
      //   userId: userId,
      //   userName: userName,
      //   text: commentController.text.trim(),
      //   timestamp: DateTime.now(),
      // );
      //
      // await commentRef.set(comment.toMap());

      // Demo: Add to local list
      final comment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        artworkId: artworkId,
        userId: userId,
        userName: userName,
        text: commentController.text.trim(),
        timestamp: DateTime.now(),
      );

      comments.insert(0, comment);
      commentController.clear();

      Get.snackbar(
        'Success',
        'Comment posted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to post comment');
    }
  }

  // Delete a comment (if user owns it)
  Future<void> deleteComment(String artworkId, String commentId) async {
    try {
      // TODO: Delete from Firestore
      // await _firestore
      //     .collection('artworks')
      //     .doc(artworkId)
      //     .collection('comments')
      //     .doc(commentId)
      //     .delete();

      comments.removeWhere((c) => c.id == commentId);

      Get.snackbar(
        'Success',
        'Comment deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete comment');
    }
  }

  List<CommentModel> _getDummyComments(String artworkId) {
    return [
      CommentModel(
        id: '1',
        artworkId: artworkId,
        userId: 'user1',
        userName: 'Emma Wilson',
        text: 'This is absolutely stunning! Love the color palette.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommentModel(
        id: '2',
        artworkId: artworkId,
        userId: 'user2',
        userName: 'Michael Brown',
        text: 'Amazing work! What software did you use?',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CommentModel(
        id: '3',
        artworkId: artworkId,
        userId: 'user3',
        userName: 'Sophie Chen',
        text: 'Beautiful composition and lighting! 🎨',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
