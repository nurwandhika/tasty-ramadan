// lib/core/models/recipe.dart
class Recipe {
  final String name;
  final String category;
  final String cuisineStyle;
  final String dietaryPreference;
  final String cookingTime;
  final List<Ingredient> ingredients;
  final List<String> cookingSteps;
  final NutritionInfo nutritionInfo;

  Recipe({
    required this.name,
    required this.category,
    required this.cuisineStyle,
    required this.dietaryPreference,
    required this.cookingTime,
    required this.ingredients,
    required this.cookingSteps,
    required this.nutritionInfo,
  });
}

class Ingredient {
  final String name;
  final String amount;

  Ingredient({required this.name, required this.amount});
}

class NutritionInfo {
  final int calories;
  final double carbs;
  final double protein;
  final double fat;

  NutritionInfo({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });
}