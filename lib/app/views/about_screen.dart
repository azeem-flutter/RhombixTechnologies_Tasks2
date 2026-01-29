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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'About ArtHub',
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
          onPressed: () => Navigator.pop(context),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Icon
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.primaryDark, const Color(0xFF9C27B0)]
                              : [AppColors.primary, const Color(0xFFBA68C8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
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
                      child: const Icon(
                        Icons.palette_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // App Name & Version
                  Center(
                    child: Column(
                      children: [
                        Text(
                          AppConstants.appName,
                          style: AppTextStyles.heading1.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Version ${AppConstants.appVersion}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Description
                  _buildSectionContainer(
                    context,
                    title: 'About',
                    children: [
                      Text(
                        AppConstants.appDescription,
                        style: AppTextStyles.body.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionContainer(
                    context,
                    title: 'Features',
                    children: [
                      _buildFeatureItem(
                        'Discover amazing artworks from talented artists',
                        isDark,
                      ),
                      _buildFeatureItem(
                        'Upload and showcase your creative work',
                        isDark,
                      ),
                      _buildFeatureItem(
                        'Like and save your favorite artworks',
                        isDark,
                      ),
                      _buildFeatureItem(
                        'Comment and engage with the community',
                        isDark,
                      ),
                      _buildFeatureItem('Follow your favorite artists', isDark),
                      _buildFeatureItem('Dark mode support', isDark),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionContainer(
                    context,
                    title: 'Contact Us',
                    children: [
                      _buildContactItem(
                        Icons.email_rounded,
                        'support@arthub.com',
                        isDark,
                      ),
                      _buildContactItem(
                        Icons.language_rounded,
                        'www.arthub.com',
                        isDark,
                      ),
                      _buildContactItem(
                        Icons.phone_rounded,
                        '+1 (555) 123-4567',
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Footer
                  Center(
                    child: Text(
                      '© 2024 ArtHub. All rights reserved.',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.heading3.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardBackgroundDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: isDark ? AppColors.success : AppColors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.primaryDark : AppColors.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
