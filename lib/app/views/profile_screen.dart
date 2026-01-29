import 'package:arthub/app/controllers/artwork_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/artwork_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Edit profile button
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black45
                  : Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _showEditProfileDialog(context, controller),
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          // Settings button
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black45
                  : Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => Get.toNamed('/settings'),
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF2D1B36),
                        AppColors.backgroundDark,
                        AppColors.cardBackgroundDark,
                      ]
                    : [const Color(0xFFF5F0FF), Colors.white, Colors.white],
              ),
            ),
          ),

          Obx(() {
            final user = controller.user;
            if (user == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Loading user data...', style: AppTextStyles.heading3),
                    const SizedBox(height: 20),
                    CircularProgressIndicator(
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardBackgroundDark
                          : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.05,
                          ),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile avatar with ring
                        GestureDetector(
                          onTap: controller
                              .updateProfileImage, // Edit profile image
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        AppColors.primaryDark,
                                        const Color(0xFF9C27B0),
                                      ]
                                    : [
                                        AppColors.primary,
                                        const Color(0xFFBA68C8),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isDark
                                              ? AppColors.primaryDark
                                              : AppColors.primary)
                                          .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ProfileAvatar(
                              imageUrl: user.profileImage,
                              size: 110,
                              showEditIcon: true,
                              onEdit: controller.updateProfileImage,
                              initials: user.name.isNotEmpty
                                  ? user.name[0]
                                  : '?',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Name & Email
                        Text(
                          user.name,
                          style: AppTextStyles.heading2.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.backgroundDark
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.email,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Bio
                        if (user.bio != null && user.bio!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isDark
                                          ? AppColors.primaryDark
                                          : AppColors.primary)
                                      .withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    (isDark
                                            ? AppColors.primaryDark
                                            : AppColors.primary)
                                        .withValues(alpha: 0.1),
                              ),
                            ),
                            child: Text(
                              user.bio!,
                              style: AppTextStyles.body.copyWith(
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Stats - wrapped in Obx for reactivity
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn(
                                controller.artworksCount.value.toString(),
                                'Artworks',
                                Icons.image_rounded,
                                isDark,
                              ),
                              _buildStatItemDivider(isDark),
                              _buildStatColumn(
                                controller.favoritesCount.value.toString(),
                                'Favorites',
                                Icons.favorite_rounded,
                                isDark,
                              ),
                              _buildStatItemDivider(isDark),
                              _buildStatColumn(
                                controller.totalViewsCount.value.toString(),
                                'Views',
                                Icons.remove_red_eye_rounded,
                                isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Artworks section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Artworks',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardBackgroundDark
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
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
                          child: Icon(
                            Icons.grid_view_rounded,
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Obx(() {
                    if (controller.userArtworks.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
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
                              'No artworks yet',
                              style: AppTextStyles.body.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => Get.toNamed('/upload'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Upload Your First Art'),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: controller.userArtworks.length,
                      itemBuilder: (context, index) {
                        final artwork = controller.userArtworks[index];
                        return ArtworkCard(
                          artwork: artwork,
                          onTap: () {
                            Get.find<ArtworkController>().selectArtwork(
                              artwork.id,
                            );
                            Get.toNamed('/artwork-details');
                          },
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    String value,
    String label,
    IconData icon,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItemDivider(bool isDark) {
    return Container(
      height: 30,
      width: 1,
      color: isDark ? Colors.grey[800] : Colors.grey[300],
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    ProfileController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBackgroundDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.nameController,
              style: AppTextStyles.body.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.bioController,
              style: AppTextStyles.body.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: 'Bio',
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateProfile();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.primaryDark
                  : AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
