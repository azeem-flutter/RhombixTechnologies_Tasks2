import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/artwork_controller.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_colors.dart';
import '../widgets/artwork_card.dart';
import '../utils/constants.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArtworkController controller = Get.find<ArtworkController>();
    final TextEditingController searchController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search artworks, artists...',
            border: InputBorder.none,
            hintStyle: AppTextStyles.body.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          onChanged: (query) => controller.searchArtworks(query),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              controller.searchArtworks('');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories
          SizedBox(
            height: 50,
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: AppConstants.categories.length,
                itemBuilder: (context, index) {
                  final category = AppConstants.categories[index];
                  final isSelected =
                      controller.selectedCategory.value == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => controller.filterByCategory(category),
                      selectedColor: isDark
                          ? AppColors.primaryDark
                          : AppColors.primary,
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Results
          Expanded(
            child: Obx(() {
              if (controller.filteredArtworks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: AppTextStyles.heading3.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try searching with different keywords',
                        style: AppTextStyles.bodySmall,
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
                itemCount: controller.filteredArtworks.length,
                itemBuilder: (context, index) {
                  final artwork = controller.filteredArtworks[index];
                  return ArtworkCard(
                    artwork: artwork,
                    onTap: () {
                      controller.selectArtwork(artwork.id);
                      Get.toNamed('/artwork-details');
                    },
                    onLike: () =>
                        controller.toggleLike(artwork.id, 'demo_user'),
                    isLiked: artwork.likedBy.contains('demo_user'),
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
