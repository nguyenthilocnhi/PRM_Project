import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/code_cryptogram_app.dart';
import 'features/game/game_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const CryptogramApp(),
    ),
  );
}