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
    final AuthController authController = Get.put(AuthController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: authController.signUpFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Account', style: AppTextStyles.heading1),
                const SizedBox(height: 8),
                Text(
                  'Join ArtHub and showcase your creativity',
                  style: AppTextStyles.body.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your name',
                  controller: authController.nameController,
                  validator: Validators.validateName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: authController.emailController,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 20),

                Obx(
                  () => CustomTextField(
                    label: 'Password',
                    hint: 'Create a password',
                    controller: authController.passwordController,
                    validator: Validators.validatePassword,
                    obscureText: !authController.isPasswordVisible.value,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        authController.isPasswordVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: authController.togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Obx(
                  () => CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    controller: authController.confirmPasswordController,
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      authController.passwordController.text,
                    ),
                    obscureText: !authController.isPasswordVisible.value,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 32),

                Obx(
                  () => CustomButton(
                    text: 'Sign Up',
                    onPressed: authController.signUp,
                    width: double.infinity,
                    isLoading: authController.isLoading.value,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.body,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
