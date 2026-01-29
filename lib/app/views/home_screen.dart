import 'package:arthub/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/artwork_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/artwork_card.dart';
import '../utils/constants.dart';
import '../services/error_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArtworkController controller = Get.find<ArtworkController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
            bottom: false,
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discover',
                            style: AppTextStyles.heading2.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find your inspiration',
                            style: AppTextStyles.body.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardBackgroundDark
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.3 : 0.05,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.search_rounded,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          onPressed: () => Get.toNamed('/search'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Category Filter
                SizedBox(
                  height: 60,
                  child: Obx(() {
                    final selectedCategory = controller.selectedCategory.value;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
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
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color:
                                              (isDark
                                                      ? AppColors.primaryDark
                                                      : AppColors.primary)
                                                  .withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: isDark ? 0.1 : 0.03,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
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

                const SizedBox(height: 8),

                // Artworks Grid
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: isDark
                              ? AppColors.primaryDark
                              : AppColors.primary,
                        ),
                      );
                    }

                    if (controller.filteredArtworks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color:
                                    (isDark
                                            ? AppColors.primaryDark
                                            : AppColors.primary)
                                        .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                size: 60,
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No artworks found',
                              style: AppTextStyles.heading3.copyWith(
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
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: controller.filteredArtworks.length,
                      itemBuilder: (context, index) {
                        final artwork = controller.filteredArtworks[index];
                        final userId =
                            AuthController.instance.currentUser.value?.id ?? '';

                        // Use stream for like state
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
      bottomNavigationBar: _buildBottomNav(context, isDark),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.primaryDark, const Color(0xFF9C27B0)]
                : [AppColors.primary, const Color(0xFFBA68C8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.primaryDark : AppColors.primary)
                  .withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Get.toNamed('/upload'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomAppBar(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        elevation: 0,
        notchMargin: 10,
        height: 80,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: true,
                onTap: () {},
                isDark: isDark,
              ),
              _buildNavItem(
                context,
                icon: Icons.favorite_rounded,
                label: 'Favorites',
                isSelected: false,
                onTap: () => Get.toNamed('/favorites'),
                isDark: isDark,
              ),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(
                context,
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: false,
                onTap: () => Get.toNamed('/profile'),
                isDark: isDark,
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: false,
                onTap: () => Get.toNamed('/settings'),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? AppColors.primaryDark : AppColors.primary)
                  : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
              size: 26,
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
