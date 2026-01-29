import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';

/// Service for centralized error handling
class ErrorService {
  /// Show error snackbar with consistent styling
  static void showError(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
      margin: EdgeInsets.all(16),
    );
  }

  /// Show success snackbar
  static void showSuccess(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  /// Show info snackbar
  static void showInfo(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  /// Handle generic errors
  static void handleError(dynamic error) {
    String message = AppConstants.errorGeneric;

    if (error is String) {
      message = error;
    } else if (error.toString().contains('network') ||
        error.toString().contains('internet')) {
      message = AppConstants.errorNetwork;
    } else if (error.toString().contains('auth') ||
        error.toString().contains('permission')) {
      message = AppConstants.errorAuth;
    }

    showError(message);
  }
}
