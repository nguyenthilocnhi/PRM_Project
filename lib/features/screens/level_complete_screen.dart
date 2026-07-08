import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

import 'package:project/features/game/game_provider.dart';
import 'package:project/features/screens/game_screen.dart';
import 'package:project/features/widgets/gradient_background.dart';
import 'package:project/features/models/level.dart';

class LevelCompleteScreen extends StatefulWidget {
  const LevelCompleteScreen({super.key});

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen> {
  late ConfettiController _confettiController;
  Level? _completedLevel;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
    
    // Store the level so it doesn't change during the transition to next level
    _completedLevel = context.read<GameProvider>().currentLevel;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final level = _completedLevel;

    if (level == null) {
      return const Scaffold(body: Center(child: Text('Error')));
    }

    final quote = level.quoteLines.join(' ');
    final author = level.author;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'LEVEL COMPLETE!',
                        style: TextStyle(
                          color: Color(0xff1e3c72),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 60),
                      
                      // Quote Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.format_quote, size: 60, color: Color(0xff45b7f5)),
                            const SizedBox(height: 16),
                            Text(
                              quote,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2d4b85),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: 50,
                              height: 4,
                              color: const Color(0xff45b7f5).withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '- $author -',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Next Level Button
                      ElevatedButton(
                        onPressed: () {
                          provider.nextLevel();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const GameScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff45b7f5),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          'NEXT LEVEL',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Back to Menu Button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'BACK TO MENU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // Downwards
              blastDirectionality: BlastDirectionality.directional,
              maxBlastForce: 15,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.yellow],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
