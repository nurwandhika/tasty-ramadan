import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tasty_ramadan/features/chat/presentation/providers/chat_provider.dart';
import 'package:tasty_ramadan/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: const TastyRamadanApp(),
    ),
  );
}