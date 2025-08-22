/// Non-visual constants for CardSense app
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://api.cardsense.ai';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration chatTimeout = Duration(seconds: 45);
  
  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Chat Configuration
  static const int maxMessageLength = 1000;
  static const int maxConversationHistory = 50;
  
  // Card Limits
  static const int maxCardsPerUser = 20;
  static const int maxCardImageSize = 5; // MB
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Debounce Delays
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration inputDebounce = Duration(milliseconds: 300);
  
  // Feature Flags
  static const bool enableDarkMode = true;
  static const bool enableBiometrics = true;
  static const bool enableAnalytics = true;
  
  // Routes
  static const String homeRoute = '/';
  static const String alertsRoute = '/alerts';
  static const String cardsRoute = '/cards';
  static const String profileRoute = '/profile';
}
