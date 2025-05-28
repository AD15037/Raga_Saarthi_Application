class Config {
  static const String apiBaseUrl = 'http://192.168.29.123:5000'; // For Android emulator

  // Auth endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String profileEndpoint = '/profile';

  // Performance endpoints
  static const String analyzePerformanceEndpoint = '/analyze_performance';

  // Recommendation endpoints
  static const String recommendationsEndpoint = '/recommendations';

  // Progress endpoints
  static const String progressEndpoint = '/progress';
}