import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // await Firebase.initializeApp();

  runApp(const ArtHubApp());
}

class ArtHubApp extends StatelessWidget {
  const ArtHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    return Obx(
      () => GetMaterialApp(
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
          ),
          GetPage(name: '/upload', page: () => const UploadScreen()),
          GetPage(name: '/profile', page: () => const ProfileScreen()),
          GetPage(name: '/favorites', page: () => const FavoritesScreen()),
          GetPage(name: '/comments', page: () => const CommentsScreen()),
          GetPage(name: '/settings', page: () => const SettingsScreen()),
          GetPage(name: '/search', page: () => const SearchScreen()),
          GetPage(name: '/about', page: () => const AboutScreen()),
        ],
      ),
    );
  }
}
