import 'package:arthub/app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Header Background
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ),
                  ),
                ),
                // Form Container
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardBackgroundDark
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.1,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: authController.signUpFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Account',
                            style: AppTextStyles.heading2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join ArtHub and showcase your creativity',
                            style: AppTextStyles.body.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          CustomTextField(
                            label: 'Full Name',
                            hint: 'Enter your name',
                            controller: authController.signUpNameController,
                            validator: Validators.validateName,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: 'Email',
                            hint: 'Enter your email',
                            controller: authController.signUpEmailController,
                            validator: Validators.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => CustomTextField(
                              label: 'Password',
                              hint: 'Create a password',
                              controller:
                                  authController.signUpPasswordController,
                              validator: Validators.validatePassword,
                              obscureText:
                                  !authController.isSignUpPasswordVisible.value,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  authController.isSignUpPasswordVisible.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: authController.toggleSignUpPassword,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => CustomTextField(
                              label: 'Confirm Password',
                              hint: 'Confirm your password',
                              controller: authController
                                  .signUpConfirmPasswordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value !=
                                    authController
                                        .signUpPasswordController
                                        .text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              obscureText: !authController
                                  .isSignUpConfirmPasswordVisible
                                  .value,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  authController
                                          .isSignUpConfirmPasswordVisible
                                          .value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed:
                                    authController.toggleSignUpConfirmPassword,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                          Obx(
                            () => CustomButton(
                              text: 'Sign Up',
                              onPressed: authController.signUp,
                              width: double.infinity,
                              isLoading: authController.isSignUpLoading.value,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: AppTextStyles.body.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    'Sign In',
                                    style: AppTextStyles.body.copyWith(
                                      color: isDark
                                          ? AppColors.primaryDark
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
