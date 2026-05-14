/// Production Cassava Guard API (Render).
abstract final class ApiConfig {
  static const String baseUrl = 'https://api-cassava.onrender.com';
  static const String analyzeCassavaPath = '/analyze-cassava';
  static Uri get analyzeCassavaUri => Uri.parse('$baseUrl$analyzeCassavaPath');
}
