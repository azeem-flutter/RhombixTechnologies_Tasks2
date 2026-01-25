class AppConstants {
  // App Info
  static const String appName = 'ArtHub';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Discover and share amazing digital artwork';

  // Categories
  static const List<String> categories = [
    'All',
    'Digital Art',
    'Photography',
    'Illustration',
    'Abstract',
    '3D Art',
    'Painting',
    'Concept Art',
    'Character Design',
  ];

  // Onboarding
  static const List<Map<String, String>> onboardingData = [
    {
      'title': 'Discover Amazing Art',
      'description':
          'Explore thousands of unique artworks from talented artists around the world',
      'icon': '🎨',
    },
    {
      'title': 'Showcase Your Talent',
      'description':
          'Share your creative work and build your digital portfolio effortlessly',
      'icon': '✨',
    },
    {
      'title': 'Connect & Inspire',
      'description':
          'Follow artists, like artworks, and be part of a creative community',
      'icon': '💫',
    },
  ];

  // Validation
  static const int minPasswordLength = 6;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String artworksCollection = 'artworks';
  static const String commentsCollection = 'comments';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection';
  static const String errorAuth = 'Authentication failed';

  // Success Messages
  static const String successUpload = 'Artwork uploaded successfully!';
  static const String successProfileUpdate = 'Profile updated successfully!';
  static const String successSignUp = 'Account created successfully!';
}
