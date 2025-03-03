import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/recipe.dart';

class GeminiService {
  Future<String> generateResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': ApiConstants.apiKey,
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.9,
            "topK": 1,
            "topP": 1,
            "maxOutputTokens": 2048,
            "stopSequences": []
          },
          "safetySettings": [
            {
              "category": "HARM_CATEGORY_HARASSMENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to generate response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating response: $e');
      rethrow;
    }
  }

  Future<Recipe> suggestRecipe(String cuisine, String dishType, String dietaryPreference, List<String> ingredients, String cookingTime) async {
    final prompt = 'Generate a detailed recipe for a $cuisine $dishType that is $dietaryPreference. The recipe should include the following ingredients: ${ingredients.join(', ')}. The cooking time should be $cookingTime.';
    final responseText = await generateResponse(prompt);
    print('Response Text: $responseText'); // Log the response text

    try {
      final data = jsonDecode(responseText);
      if (data is! Map) {
        throw FormatException('Unexpected response format');
      }
      final recipe = Recipe(
        name: data['name'],
        category: data['category'],
        cuisineStyle: data['cuisineStyle'],
        dietaryPreference: data['dietaryPreference'],
        cookingTime: data['cookingTime'],
        ingredients: (data['ingredients'] as List)
            .map((i) => Ingredient(name: i['name'], amount: i['amount']))
            .toList(),
        cookingSteps: List<String>.from(data['cookingSteps']),
        nutritionInfo: NutritionInfo(
          calories: data['nutritionInfo']['calories'],
          carbs: data['nutritionInfo']['carbs'],
          protein: data['nutritionInfo']['protein'],
          fat: data['nutritionInfo']['fat'],
        ),
      );
      return recipe;
    } catch (e) {
      print('Error parsing response: $e');
      rethrow;
    }
  }
}