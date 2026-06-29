import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/code_cryptogram_app.dart';
import 'features/game/game_provider.dart';
import 'features/settings/settings_provider.dart';
import 'features/game/storage_service.dart';
import 'features/game/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioManager().init();
  final storageService = StorageService();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(storageService)),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const CryptogramApp(),
    ),
  );
}