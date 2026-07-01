import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project/features/game/game_provider.dart';
import 'package:project/features/screens/game_screen.dart';
import 'package:project/features/widgets/gradient_background.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final levels = provider.allLevels;
    final maxUnlocked = provider.maxUnlockedLevel;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'SELECT LEVEL',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          centerTitle: true,
        ),
        body: levels.isEmpty 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              final isUnlocked = level.id <= maxUnlocked;

              return GestureDetector(
                onTap: isUnlocked ? () async {
                  await provider.loadLevel(level.id);
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  }
                } : null,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isUnlocked 
                      ? const LinearGradient(
                          colors: [Colors.white, Color(0xffe6f4ff)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                    color: isUnlocked ? null : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUnlocked ? Colors.white : Colors.white24,
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (isUnlocked)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                    ],
                  ),
                  child: Center(
                    child: isUnlocked
                        ? Text(
                            '${level.id}',
                            style: const TextStyle(
                              color: Color(0xff1e3c72),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        : const Icon(
                            Icons.lock,
                            color: Colors.white54,
                            size: 28,
                          ),
                  ),
                ),
              );
            },
          ),
      ),
    );
  }
}
