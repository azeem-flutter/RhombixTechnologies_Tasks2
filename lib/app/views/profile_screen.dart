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
    final ProfileController controller = Get.put(ProfileController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user.value;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Profile Avatar
              Obx(
                () => ProfileAvatar(
                  imageUrl: user.profileImage,
                  size: 120,
                  showEditIcon: true,
                  onEdit: controller.updateProfileImage,
                  initials: user.name[0],
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(user.name, style: AppTextStyles.heading2),
              const SizedBox(height: 4),

              // Email
              Text(
                user.email,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              // Bio
              if (user.bio != null && user.bio!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    user.bio!,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(
                    '${controller.userArtworks.length}',
                    'Artworks',
                  ),
                  _buildStatColumn('${user.favorites.length}', 'Favorites'),
                  _buildStatColumn('0', 'Followers'),
                ],
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),

              // User Artworks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('My Artworks', style: AppTextStyles.heading3),
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
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 60,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text('No artworks yet', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: controller.userArtworks.length,
                  itemBuilder: (context, index) {
                    final artwork = controller.userArtworks[index];
                    return ArtworkCard(
                      artwork: artwork,
                      onTap: () {
                        Get.find<ArtworkController>().selectArtwork(artwork.id);
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
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading2),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
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
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.updateProfile();
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
