import 'package:arthub/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/artwork_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/artwork_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // Helper method to get favorite artwork IDs for a user
  Future<List<String>> _getFavoriteArtworkIds(
    ArtworkController controller,
    String userId,
  ) async {
    final favoriteIds = <String>[];
    for (final artwork in controller.artworks) {
      // Check if user has liked this artwork
      final stream = controller.isLikedStream(artwork.id, userId);
      final isLiked = await stream.first;
      if (isLiked) {
        favoriteIds.add(artwork.id);
      }
    }
    return favoriteIds;
  }

  @override
  Widget build(BuildContext context) {
    final ArtworkController artworkController = Get.find<ArtworkController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.backgroundDark,
                        const Color(0xFF2D1B36),
                        AppColors.cardBackgroundDark,
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.05),
                        Colors.white,
                        const Color(0xFFF5F0FF),
                      ],
              ),
            ),
          ),

          SafeArea(
            child: Obx(() {
              final userId = AuthController.instance.currentUser.value?.id;
              if (userId == null) {
                return Center(
                  child: Text(
                    'Please sign in to view favorites',
                    style: AppTextStyles.body.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              }

              // Build a list of favorite artworks by checking each one's like status
              return FutureBuilder<List<String>>(
                future: _getFavoriteArtworkIds(artworkController, userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primary,
                      ),
                    );
                  }

                  final favoriteIds = snapshot.data ?? [];

                  if (favoriteIds.isEmpty) {
                    return Center(
                      child: Text(
                        'No favorites yet',
                        style: AppTextStyles.body.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  // Filter artworks to only show favorites
                  final favoriteArtworks = artworkController.artworks
                      .where((art) => favoriteIds.contains(art.id))
                      .toList();

                  return GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: favoriteArtworks.length,
                    itemBuilder: (context, index) {
                      final artwork = favoriteArtworks[index];

                      return ArtworkCard(
                        artwork: artwork,
                        onTap: () {
                          artworkController.selectArtwork(artwork.id);
                          Get.toNamed('/artwork-details');
                        },
                        onLike: () {
                          if (userId.isNotEmpty) {
                            artworkController.toggleLike(artwork.id, userId);
                          }
                        },
                        isLiked: true,
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
