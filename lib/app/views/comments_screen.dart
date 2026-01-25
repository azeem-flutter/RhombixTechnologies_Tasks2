import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/comments_controller.dart';
import '../themes/app_text_styles.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/custom_button.dart';
import 'package:intl/intl.dart';

class CommentsScreen extends StatelessWidget {
  const CommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CommentsController controller = Get.find<CommentsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.comments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.comment_outlined, size: 60),
                      const SizedBox(height: 16),
                      Text('No comments yet', style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to comment!',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.comments.length,
                itemBuilder: (context, index) {
                  final comment = controller.comments[index];
                  return ListTile(
                    leading: ProfileAvatar(
                      imageUrl: comment.userImage,
                      size: 40,
                      initials: comment.userName[0],
                    ),
                    title: Text(
                      comment.userName,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(comment.text),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy • h:mm a',
                          ).format(comment.timestamp),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              );
            }),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    controller.addComment(
                      'artwork_id',
                      'demo_user',
                      'John Doe',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
