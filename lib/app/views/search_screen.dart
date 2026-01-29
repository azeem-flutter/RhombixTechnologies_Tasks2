import 'package:arthub/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/artwork_controller.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_colors.dart';
import '../widgets/artwork_card.dart';
import '../utils/constants.dart';
import '../services/error_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ArtworkController controller = Get.find<ArtworkController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
            child: Column(
              children: [
                // Search Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardBackgroundDark
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.05,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      style: AppTextStyles.body.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search artworks, artists...',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            searchController.clear();
                            controller.searchArtworks('');
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (query) => controller.searchArtworks(query),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Categories
                SizedBox(
                  height: 45,
                  child: Obx(() {
                    final selectedCategory = controller.selectedCategory.value;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: AppConstants.categories.length,
                      itemBuilder: (context, index) {
                        final category = AppConstants.categories[index];
                        final isSelected = selectedCategory == category;

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => controller.filterByCategory(category),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                          ? AppColors.primaryDark
                                          : AppColors.primary)
                                    : (isDark
                                          ? AppColors.cardBackgroundDark
                                                .withValues(alpha: 0.5)
                                          : Colors.white),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isDark
                                            ? Colors.grey[800]!
                                            : Colors.grey[200]!),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondary),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Results
                Expanded(
                  child: Obx(() {
                    if (controller.filteredArtworks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color:
                                    (isDark
                                            ? AppColors.primaryDark
                                            : AppColors.primary)
                                        .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 60,
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
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
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: controller.filteredArtworks.length,
                      itemBuilder: (context, index) {
                        final artwork = controller.filteredArtworks[index];
                        final userId =
                            AuthController.instance.currentUser.value?.id ?? '';

                        return StreamBuilder<bool>(
                          stream: controller.isLikedStream(artwork.id, userId),
                          initialData: false,
                          builder: (context, snapshot) {
                            final isLiked = snapshot.data ?? false;
                            return ArtworkCard(
                              artwork: artwork,
                              onTap: () {
                                controller.selectArtwork(artwork.id);
                                Get.toNamed('/artwork-details');
                              },
                              onLike: () {
                                if (userId.isNotEmpty) {
                                  controller.toggleLike(artwork.id, userId);
                                } else {
                                  ErrorService.showError(
                                    'Please sign in to like artwork',
                                  );
                                }
                              },
                              isLiked: isLiked,
                            );
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
