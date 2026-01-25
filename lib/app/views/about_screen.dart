import 'package:flutter/material.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_colors.dart';
import '../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('About ArtHub')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.palette, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),

            // App Name & Version
            Center(
              child: Column(
                children: [
                  Text(AppConstants.appName, style: AppTextStyles.heading1),
                  const SizedBox(height: 8),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Description
            Text('About', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            Text(AppConstants.appDescription, style: AppTextStyles.body),
            const SizedBox(height: 24),

            Text('Features', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            _buildFeatureItem(
              'Discover amazing artworks from talented artists',
            ),
            _buildFeatureItem('Upload and showcase your creative work'),
            _buildFeatureItem('Like and save your favorite artworks'),
            _buildFeatureItem('Comment and engage with the community'),
            _buildFeatureItem('Follow your favorite artists'),
            _buildFeatureItem('Dark mode support'),
            const SizedBox(height: 24),

            Text('Contact Us', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            _buildContactItem(Icons.email, 'support@arthub.com'),
            _buildContactItem(Icons.language, 'www.arthub.com'),
            _buildContactItem(Icons.phone, '+1 (555) 123-4567'),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Text(
                '© 2024 ArtHub. All rights reserved.',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 20, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(text, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
