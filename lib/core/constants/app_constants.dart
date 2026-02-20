class AppConstants {
  AppConstants._();

  static const String appName = 'Cleaning Soluciones LLC';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String ordersCollection = 'orders';
  static const String messagesCollection = 'messages';
  static const String expensesCollection = 'expenses';
  static const String pricesCollection = 'prices';

  // User Roles
  static const String roleClient = 'client';
  static const String roleAdmin = 'admin';

  // Order Statuses
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusPaymentApproved = 'payment_approved';

  // Payment Methods
  static const String paymentZelle = 'Zelle';
  static const String paymentVenmo = 'Venmo';

  // Payment Info
  static const String zelleInfo = 'Zelle: arturosojovivas@gmail.com';
  static const String venmoInfo = 'Venmo: @CleaningSoluciones';

  // SQLite
  static const String dbName = 'cleaning_soluciones.db';
  static const int dbVersion = 1;
  static const String tableUserPrefs = 'user_preferences';
  static const String tableRecentOrders = 'recent_orders';
  static const String tableCachedPrices = 'cached_prices';

  // SharedPreferences Keys
  static const String keyLocale = 'locale';
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';

  // Supported Locales
  static const List<String> supportedLocales = ['en', 'es', 'fr'];

  // Storage Paths
  static const String storagePaymentProofs = 'payment_proofs';
  static const String storageProfileImages = 'profile_images';

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);
}
