import 'package:arthub/app/controllers/auth_controller.dart';
import 'package:arthub/app/repositories/comment_repository.dart';
import 'package:arthub/app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/comment_model.dart';
import '../services/error_service.dart';

class CommentsController extends GetxController {
  final CommentRepository _repo = CommentRepository();

  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxBool isLoading = false.obs;
  final TextEditingController commentController = TextEditingController();

  UserModel? get _currentUser {
    try {
      return Get.find<AuthController>().currentUser.value;
    } catch (_) {
      return null;
    }
  }

  // FETCH
  Future<void> fetchComments(String artworkId) async {
    try {
      isLoading.value = true;
      comments.value = await _repo.fetchComments(artworkId);
    } catch (e) {
      ErrorService.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ADD
  Future<void> addComment(String artworkId) async {
    final user = _currentUser;

    if (user == null) {
      ErrorService.showError('Login required');
      return;
    }

    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final comment = CommentModel(
      id: FirebaseFirestore.instance.collection('_').doc().id,
      artworkId: artworkId,
      userId: user.id,
      userName: user.name,
      userImage: user.profileImage,
      text: text,
      createdAt: DateTime.now(),
    );

    try {
      await _repo.addComment(comment);
      comments.insert(0, comment);
      commentController.clear();
    } catch (e) {
      ErrorService.handleError(e);
    }
  }

  // DELETE
  Future<void> deleteComment({
    required String artworkId,
    required String commentId,
  }) async {
    final user = _currentUser;
    if (user == null) return;

    final comment = comments.firstWhere((c) => c.id == commentId);

    if (comment.userId != user.id) {
      ErrorService.showError('You can delete only your own comment');
      return;
    }

    try {
      await _repo.deleteComment(artworkId: artworkId, commentId: commentId);
      comments.removeWhere((c) => c.id == commentId);
    } catch (e) {
      ErrorService.handleError(e);
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
