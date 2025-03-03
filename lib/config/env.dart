class Env {
  static String getApiKey() {
    const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (apiKey.isEmpty) {
      throw Exception('API key not found');
    }
    return apiKey;
  }
}