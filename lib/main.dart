import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app/code_cryptogram_app.dart';
import 'features/game/game_provider.dart';
import 'features/settings/settings_provider.dart';
import 'features/game/storage_service.dart';
import 'features/game/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xfffff8df),
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  await AudioManager().init();
  final storageService = StorageService();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(storageService), lazy: false),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const CryptogramApp(),
    ),
  );
}