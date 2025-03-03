class Env {
  static String getApiKey() {
    const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is not set. Please run with --dart-define=GEMINI_API_KEY=your_key');
    }
    return apiKey;
  }
}