import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasty_ramadan/features/chat/presentation/providers/chat_provider.dart';
import 'package:tasty_ramadan/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: const TastyRamadanApp(),
    ),
  );
}