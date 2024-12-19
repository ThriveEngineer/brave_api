class BraveSearchConfig {
  static String? _apiKey;

  /// Initialize the Brave Search configuration
  static void initialize({required String apiKey}) {
    _apiKey = apiKey;
  }

  /// Get the API key
  static String get apiKey {
    if (_apiKey == null) {
      throw Exception('BraveSearchConfig must be initialized with an API key before use.');
    }
    return _apiKey!;
  }
}