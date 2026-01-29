import 'package:arthub/app/controllers/artwork_controller.dart';
import 'package:arthub/app/controllers/auth_controller.dart';
import 'package:arthub/app/controllers/comments_controller.dart';
import 'package:arthub/app/controllers/profile_controller.dart';
import 'package:get/get.dart';

/// Initial binding for app-wide controllers
/// These controllers are permanent and persist throughout the app lifecycle
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Permanent controllers - persist throughout app lifecycle
    Get.put(AuthController(), permanent: true);
    Get.put(ArtworkController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
  }
}

/// Binding for profile-related screens
/// ProfileController is lazy-loaded when needed

/// Binding for comments-related screens
/// CommentsController is lazy-loaded when needed and disposed when not in use
class CommentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CommentsController(), fenix: true);
  }
}
