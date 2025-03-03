import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class RecipeDetailPage extends StatelessWidget {
  final Future<String> recipeFuture;

  const RecipeDetailPage({super.key, required this.recipeFuture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Detail'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<String>(
        future: recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                  ),
                ),
                Center(
                  child: Lottie.asset(
                    'assets/animations/cooking.json', // Add your Lottie animation file here
                    height: 200,
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return FutureBuilder<void>(
              future: Future.delayed(const Duration(seconds: 2)),
              builder: (context, delaySnapshot) {
                if (delaySnapshot.connectionState == ConnectionState.waiting) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                        ),
                      ),
                      Center(
                        child: Lottie.asset(
                          'assets/animations/cooking.json', // Add your Lottie animation file here
                          height: 200,
                        ),
                      ),
                    ],
                  );
                } else {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: MarkdownBody(
                          data: snapshot.data!,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(color: Color(0xFF1A1A1D)),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}