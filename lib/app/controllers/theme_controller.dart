import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadThemePreference();
  }

  // Load theme preference from local storage
  Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  // Toggle theme and save preference
  Future<void> toggleTheme() async {
    try {
      isDarkMode.value = !isDarkMode.value;
      update();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode.value);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }
}
