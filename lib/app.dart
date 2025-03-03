// lib/app.dart
import 'package:flutter/material.dart';
import 'package:tasty_ramadan/features/chat/presentation/pages/chat_page.dart';

class TastyRamadanApp extends StatelessWidget {
  const TastyRamadanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tasty Ramadan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const ChatPage(), // Changed from HomePage to ChatPage
    );
  }
}