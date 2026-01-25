import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/artwork_controller.dart';
import '../controllers/profile_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/artwork_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArtworkController artworkController = Get.find<ArtworkController>();
    final ProfileController profileController = Get.find<ProfileController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Obx(() {
        final favoriteIds = profileController.user.value?.favorites ?? [];
        final favoriteArtworks = artworkController.artworks
            .where((artwork) => artwork.likedBy.contains('demo_user'))
            .toList();

        if (favoriteArtworks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 80,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: AppTextStyles.heading3.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start exploring and save artworks you love',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
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
              onLike: () =>
                  artworkController.toggleLike(artwork.id, 'demo_user'),
              isLiked: true,
            );
          },
        );
      }),
    );
  }
}
