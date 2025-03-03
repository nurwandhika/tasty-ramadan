import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get apiKey {
    const key = String.fromEnvironment('GEMINI_API_KEY');
    if (key.isEmpty) {
      throw Exception('GEMINI_API_KEY not set. Run with --dart-define=GEMINI_API_KEY=your_key');
    }
    return key;
  }

  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-002:generateContent';
}