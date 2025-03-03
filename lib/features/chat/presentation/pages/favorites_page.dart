import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import 'recipe_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  String extractTitle(String recipe) {
    final titleMatch = RegExp(r'## (.+)').firstMatch(recipe);
    return titleMatch != null
        ? titleMatch.group(1) ?? 'Untitled Recipe'
        : 'Untitled Recipe';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          return ListView.builder(
            itemCount: chatProvider.favoriteRecipes.length,
            itemBuilder: (context, index) {
              final recipe = chatProvider.favoriteRecipes[index];
              final title = extractTitle(recipe);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      color: Color(0xFF1A1A1D),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(
                          recipeFuture: Future.value(recipe),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}