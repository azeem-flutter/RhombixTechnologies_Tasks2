import 'package:arthub/binding/binding.dart';
import 'package:arthub/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'app/themes/app_theme.dart';
import 'app/controllers/theme_controller.dart';
import 'app/views/splash_screen.dart';
import 'app/views/onboarding_screen.dart';
import 'app/views/signin_screen.dart';
import 'app/views/signup_screen.dart';
import 'app/views/home_screen.dart';
import 'app/views/artwork_details_screen.dart';
import 'app/views/upload_screen.dart';
import 'app/views/profile_screen.dart';
import 'app/views/favorites_screen.dart';
import 'app/views/comments_screen.dart';
import 'app/views/settings_screen.dart';
import 'app/views/search_screen.dart';
import 'app/views/about_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  Get.put(ThemeController(), permanent: true);

  await GetStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ArtHubApp());
}

class ArtHubApp extends StatelessWidget {
  const ArtHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          initialBinding: InitialBinding(),
          title: 'ArtHub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: '/splash',
          getPages: [
            GetPage(name: '/splash', page: () => const SplashScreen()),
            GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
            GetPage(name: '/signin', page: () => const SignInScreen()),
            GetPage(name: '/signup', page: () => const SignUpScreen()),
            GetPage(name: '/home', page: () => const HomeScreen()),
            GetPage(
              name: '/artwork-details',
              page: () => const ArtworkDetailsScreen(),
              binding: CommentsBinding(),
            ),
            GetPage(name: '/upload', page: () => UploadScreen()),
            GetPage(name: '/profile', page: () => const ProfileScreen()),
            GetPage(name: '/favorites', page: () => const FavoritesScreen()),
            GetPage(
              name: '/comments',
              page: () => const CommentsScreen(),
              binding: CommentsBinding(),
            ),
            GetPage(name: '/settings', page: () => const SettingsScreen()),
            GetPage(name: '/search', page: () => const SearchScreen()),
            GetPage(name: '/about', page: () => const AboutScreen()),
          ],
        );
      },
    );
  }
}
