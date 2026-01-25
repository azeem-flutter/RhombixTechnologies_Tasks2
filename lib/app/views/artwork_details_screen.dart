import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/artwork_controller.dart';
import '../controllers/comments_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/profile_avatar.dart';
import 'package:intl/intl.dart';

class ArtworkDetailsScreen extends StatelessWidget {
  const ArtworkDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArtworkController artworkController = Get.find<ArtworkController>();
    final CommentsController commentsController = Get.put(CommentsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final artwork = artworkController.selectedArtwork.value;
      if (artwork == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Artwork')),
          body: const Center(child: Text('Artwork not found')),
        );
      }

      commentsController.fetchComments(artwork.id);
      artworkController.incrementViews(artwork.id);

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar with Image
            SliverAppBar(
              expandedHeight: 400,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: CachedNetworkImage(
                  imageUrl: artwork.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    Get.snackbar('Info', 'Share functionality coming soon');
                  },
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Category
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            artwork.title,
                            style: AppTextStyles.heading2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primaryDark.withOpacity(0.2)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            artwork.category,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Artist Info
                    Row(
                      children: [
                        ProfileAvatar(
                          imageUrl: artwork.artistImage,
                          size: 50,
                          initials: artwork.artistName[0],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                artwork.artistName,
                                style: AppTextStyles.heading4,
                              ),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(artwork.createdAt),
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.snackbar('Info', 'Follow feature coming soon');
                          },
                          child: const Text('Follow'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats
                    Row(
                      children: [
                        _buildStatItem(
                          Icons.favorite,
                          '${artwork.likes}',
                          isDark,
                        ),
                        const SizedBox(width: 20),
                        _buildStatItem(
                          Icons.visibility,
                          '${artwork.views}',
                          isDark,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            artwork.likedBy.contains('demo_user')
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: artwork.likedBy.contains('demo_user')
                                ? AppColors.error
                                : null,
                          ),
                          onPressed: () {
                            artworkController.toggleLike(
                              artwork.id,
                              'demo_user',
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),

                    // Description
                    Text('Description', style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    Text(artwork.description, style: AppTextStyles.body),
                    const SizedBox(height: 30),

                    // Comments Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Comments', style: AppTextStyles.heading3),
                        TextButton(
                          onPressed: () {
                            Get.toNamed('/comments');
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Obx(() {
                      if (commentsController.comments.isEmpty) {
                        return Text(
                          'No comments yet. Be the first!',
                          style: AppTextStyles.bodySmall,
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: commentsController.comments.take(3).length,
                        itemBuilder: (context, index) {
                          final comment = commentsController.comments[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
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
                            subtitle: Text(comment.text),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(IconData icon, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(value, style: AppTextStyles.body),
      ],
    );
  }
}
