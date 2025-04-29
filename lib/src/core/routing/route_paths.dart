/// Constants for route paths used in the application.
///
/// This class provides a centralized place for all route paths,
/// making it easier to maintain and update routes.
class RoutePaths {
  // Private constructor to prevent instantiation
  RoutePaths._();

  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main routes
  static const String home = '/';
  static const String settings = '/settings';
  static const String profile = '/profile';
  
  // Settings sub-routes
  static const String theme = 'theme';
  static const String notifications = 'notifications';
  
  // Profile sub-routes
  static const String editProfile = 'edit';
  static const String changePassword = 'change-password';
  
  // Dynamic routes
  static const String userDetails = '/user/:id';
  static const String itemDetails = '/item/:id';
  
  // Helper methods for dynamic routes
  static String userDetailsPath(String id) => '/user/$id';
  static String itemDetailsPath(String id) => '/item/$id';
}
