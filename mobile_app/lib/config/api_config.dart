class ApiConfig {
  // L'URL de base de votre API Flask
  static const String baseUrl = 'http://10.0.2.2:5000';  // Pour l'émulateur Android
  // static const String baseUrl = 'http://localhost:5000';  // Pour iOS ou le web
  
  // Les endpoints de l'API
  static const String signupEndpoint = '/signup';
  static const String loginEndpoint = '/login';
  static const String uploadEndpoint = '/ocr';
  
  // Les URLs complètes
  static String get signupUrl => baseUrl + signupEndpoint;
  static String get loginUrl => baseUrl + loginEndpoint;
  static String get uploadUrl => baseUrl + uploadEndpoint;
} 