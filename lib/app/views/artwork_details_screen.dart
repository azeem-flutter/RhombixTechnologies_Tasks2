import 'package:arthub/app/controllers/auth_controller.dart';
import 'package:arthub/app/controllers/profile_controller.dart';
import 'package:arthub/app/services/error_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/artwork_controller.dart';
import '../controllers/comments_controller.dart';
import '../repositories/artwork_repository.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/profile_avatar.dart';
import 'package:intl/intl.dart';

class ArtworkDetailsScreen extends StatefulWidget {
  const ArtworkDetailsScreen({super.key});

  @override
  State<ArtworkDetailsScreen> createState() => _ArtworkDetailsScreenState();
}

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
        if (user != null) {
          artworkController.incrementViewOnce(artwork.id, user.id);
        }
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

  @override
  Widget build(BuildContext context) {
    final ArtworkController artworkController = Get.find<ArtworkController>();
    final CommentsController commentsController =
        Get.find<CommentsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final artwork = artworkController.selectedArtwork;
      if (artwork == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Artwork')),
          body: const Center(child: Text('Artwork not found')),
        );
      }

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar with Image
            SliverAppBar(
              expandedHeight: 400,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'artwork_${artwork.id}',
                      child: CachedNetworkImage(
                        imageUrl: artwork.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black45,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black54,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      Get.snackbar('Info', 'Share functionality coming soon');
                    },
                  ),
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Container(
                transform: Matrix4.translationValues(0, -20, 0),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Title and Category
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            artwork.title,
                            style: AppTextStyles.heading2.copyWith(
                              fontSize: 28,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primaryDark.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.primaryDark.withValues(alpha: 0.3)
                                  : AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            artwork.category,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Artist Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardBackgroundDark
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.05,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ProfileAvatar(
                            imageUrl: _artistImage.isNotEmpty
                                ? _artistImage
                                : artwork.artistImage,
                            size: 50,
                            initials: artwork.artistName[0],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  artwork.artistName,
                                  style: AppTextStyles.heading4.copyWith(
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(artwork.createdAt.toDate()),
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardBackgroundDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Likes count from stream
                          StreamBuilder<int>(
                            stream: artworkController.getLikeCountStream(
                              artwork.id,
                            ),
                            initialData: 0,
                            builder: (context, snapshot) {
                              final likeCount = snapshot.data ?? 0;
                              return _buildStatItem(
                                Icons.favorite_rounded,
                                '$likeCount',
                                'Likes',
                                isDark,
                              );
                            },
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                          ),
                          // Views count from stream
                          StreamBuilder<int>(
                            stream: artworkController.getViewCountStream(
                              artwork.id,
                            ),
                            initialData: 0,
                            builder: (context, snapshot) {
                              final viewCount = snapshot.data ?? 0;
                              return _buildStatItem(
                                Icons.visibility_rounded,
                                '$viewCount',
                                'Views',
                                isDark,
                              );
                            },
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                          ),
                          // Like button from stream
                          StreamBuilder<bool>(
                            stream: artworkController.isLikedStream(
                              artwork.id,
                              AuthController.instance.currentUser.value?.id ??
                                  '',
                            ),
                            initialData: false,
                            builder: (context, snapshot) {
                              final isLiked = snapshot.data ?? false;
                              return IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isLiked
                                      ? AppColors.error
                                      : (isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600]),
                                  size: 28,
                                ),
                                onPressed: () {
                                  final user =
                                      AuthController.instance.currentUser.value;

                                  if (user == null) {
                                    ErrorService.showError(
                                      'Please sign in to like artwork',
                                    );
                                    return;
                                  }

                                  artworkController.toggleLike(
                                    artwork.id,
                                    user.id,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Description
                    Text(
                      'Description',
                      style: AppTextStyles.heading3.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      artwork.description,
                      style: AppTextStyles.body.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Comments Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments',
                          style: AppTextStyles.heading3.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed('/comments'),
                          child: Text(
                            'View All',
                            style: AppTextStyles.body.copyWith(
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

                    Obx(() {
                      if (commentsController.comments.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'No comments yet. Be the first!',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: commentsController.comments.take(3).length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final comment = commentsController.comments[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardBackgroundDark
                                  : AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.03,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProfileAvatar(
                                  imageUrl: comment.userImage,
                                  size: 40,
                                  initials: comment.userName[0],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment.userName,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment.text,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: AppTextStyles.heading4.copyWith(
                fontSize: 16,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 11,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
