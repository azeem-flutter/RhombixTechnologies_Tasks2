import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

/// Service to manage current user information
/// Provides a centralized way to access current user data
class UserService {
  static String? get currentUserId {
    final authController = Get.find<AuthController>();
    return authController.currentUser.value?.id;
  }

  static UserModel? get currentUser {
    final authController = Get.find<AuthController>();
    return authController.currentUser.value;
  }

  static String get currentUserName {
    final user = currentUser;
    return user?.name ?? 'Guest';
  }

  static bool get isAuthenticated {
    return currentUserId != null;
  }
}
