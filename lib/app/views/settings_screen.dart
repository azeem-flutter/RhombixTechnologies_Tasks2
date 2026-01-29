import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/auth_controller.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final AuthController authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Settings',
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
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Appearance Section
                _buildSectionHeader('Appearance', isDark),
                _buildSettingsContainer(
                  context,
                  children: [
                    Obx(
                      () => _buildSettingsTile(
                        context,
                        icon: themeController.isDarkMode.value
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        title: 'Dark Mode',
                        trailing: Switch.adaptive(
                          value: themeController.isDarkMode.value,
                          onChanged: (_) => themeController.toggleTheme(),
                          activeTrackColor: AppColors.primary,
                        ),
                        onTap: () => themeController.toggleTheme(),
                        showDivider: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Account Section
                _buildSectionHeader('Account', isDark),
                _buildSettingsContainer(
                  context,
                  children: [
                    _buildSettingsTile(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      onTap: () => Get.toNamed('/profile'),
                    ),
                    _buildSettingsTile(
                      context,
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      onTap: () => Get.snackbar(
                        'Coming Soon',
                        'Change password feature will be available soon',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: isDark
                            ? AppColors.cardBackgroundDark
                            : Colors.white,
                        colorText: isDark ? Colors.white : Colors.black87,
                        margin: const EdgeInsets.all(20),
                        borderRadius: 20,
                      ),
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // About Section
                _buildSectionHeader('About', isDark),
                _buildSettingsContainer(
                  context,
                  children: [
                    _buildSettingsTile(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: 'About ArtHub',
                      onTap: () => Get.toNamed('/about'),
                    ),
                    _buildSettingsTile(
                      context,
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      onTap: () => Get.snackbar(
                        'Coming Soon',
                        'Terms & Conditions will be available soon',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: isDark
                            ? AppColors.cardBackgroundDark
                            : Colors.white,
                        colorText: isDark ? Colors.white : Colors.black87,
                        margin: const EdgeInsets.all(20),
                        borderRadius: 20,
                      ),
                    ),
                    _buildSettingsTile(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => Get.snackbar(
                        'Coming Soon',
                        'Privacy Policy will be available soon',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: isDark
                            ? AppColors.cardBackgroundDark
                            : Colors.white,
                        colorText: isDark ? Colors.white : Colors.black87,
                        margin: const EdgeInsets.all(20),
                        borderRadius: 20,
                      ),
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Logout Button
                _buildSettingsContainer(
                  context,
                  children: [
                    _buildSettingsTile(
                      context,
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      iconColor: AppColors.error,
                      textColor: AppColors.error,
                      onTap: () => _showLogoutDialog(context, authController),
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // App Version
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.05),
                        ),
                        child: Image.asset(
                          'assets/images/logo.png', // Assuming logo exists, fallback to icon if not
                          width: 32,
                          height: 32,
                          errorBuilder: (c, o, s) => Icon(
                            Icons.palette_rounded,
                            size: 32,
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Version 1.0.0',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
    bool showDivider = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white70 : Colors.black87;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.primary).withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: textColor ?? defaultColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    trailing
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.white30 : Colors.black26,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 60,
            color: isDark ? Colors.white10 : Colors.grey[100],
          ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              authController.signOut();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
