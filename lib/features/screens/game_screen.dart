import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/features/game/game_provider.dart';
import 'package:project/features/screens/level_complete_screen.dart';
import 'package:project/features/widgets/clue_card.dart';
import 'package:project/features/widgets/game_keyboard.dart';
import 'package:project/features/widgets/puzzle_word_view.dart';
import 'package:project/features/screens/settings_screen.dart';
import 'package:project/features/screens/tutorial_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int? _selectedNumber;
  bool _isDialogShowing = false;
  bool _isGameOverDialogShowing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onNumberSelected(int number) {
    setState(() {
      _selectedNumber = number;
    });
  }

  void _onKeyTap(String letter) {
    if (_selectedNumber != null) {
      context.read<GameProvider>().inputLetter(_selectedNumber!, letter);
    }
  }

  void _onLeftArrow() {
    _navigateCell(-1);
  }

  void _onRightArrow() {
    _navigateCell(1);
  }

  void _navigateCell(int direction) {
    final provider = context.read<GameProvider>();
    final level = provider.currentLevel;
    if (level == null) return;
    
    // Get visual order of empty cells
    final List<int> emptyCells = [];
    for (String line in level.quoteLines) {
      for (String word in line.split(' ')) {
        for (String letter in word.split('')) {
          final number = provider.cipherMap[letter];
          if (number != null && !provider.userInputs.containsKey(number) && !emptyCells.contains(number)) {
             emptyCells.add(number);
          }
        }
      }
    }
    
    // Also add any empty cells from clues that aren't in the quote
    for (var clue in level.clues) {
      for (int i = 0; i < clue.answer.length; i++) {
          final letter = clue.answer[i];
          final number = provider.cipherMap[letter];
          if (number != null && !provider.userInputs.containsKey(number) && !emptyCells.contains(number)) {
             emptyCells.add(number);
          }
      }
    }
    
    if (emptyCells.isEmpty) return;

    int currentIndex = -1;
    if (_selectedNumber != null) {
      currentIndex = emptyCells.indexOf(_selectedNumber!);
    }

    if (currentIndex == -1) {
      // If current selected is not in empty list (or null), just select the first one
      _onNumberSelected(emptyCells.first);
    } else {
      int nextIndex = (currentIndex + direction) % emptyCells.length;
      if (nextIndex < 0) nextIndex += emptyCells.length;
      _onNumberSelected(emptyCells[nextIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xff45b7f5),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final level = provider.currentLevel;

    if (level == null) {
      return const Scaffold(
        body: Center(
          child: Text('No levels found'),
        ),
      );
    }

    // Auto check win
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.isLevelComplete && !_isDialogShowing) {
        _isDialogShowing = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!context.mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LevelCompleteScreen()),
          );
        });
      }
      
      if (provider.isGameOver && !_isGameOverDialogShowing) {
        _isGameOverDialogShowing = true;
        _showGameOverDialog(context, provider);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xfffff8df),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(level.title),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: _buildGameContent(provider),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _buildHintButton(provider),
                  ),
                ],
              ),
            ),
            GameKeyboard(
              usedLetters: provider.userInputs.values.toSet(),
              disabledLetters: List<String>.from(level.disabledLetters),
              onKeyTap: _onKeyTap,
              onLeftArrow: _onLeftArrow,
              onRightArrow: _onRightArrow,
            ),
          ],
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Game Over', style: TextStyle(color: Colors.red)),
        content: const Text('You made 3 mistakes. Try again!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _isGameOverDialogShowing = false;
              provider.restartLevel();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff2d4b85), // Đổi màu chữ sang xanh đậm để nổi bật trên nền sáng
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black54,
                    builder: (context) => const TutorialDialog(),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.black87),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black54,
                    builder: (context) => const SettingsDialog(isGameScreen: true),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.settings, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildGameContent(GameProvider provider) {
    final level = provider.currentLevel!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      child: Column(
        children: [
          const SizedBox(height: 10),

          _buildStrikes(provider.errorsCount),

          const SizedBox(height: 16),

          const Text(
            'S O L U T I O N',
            style: TextStyle(
              color: Colors.black38,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ),

          const SizedBox(height: 18),

          PuzzleWordView(
            lines: level.quoteLines,
            userGuesses: provider.userInputs,
            cipherMap: provider.cipherMap,
            selectedNumber: _selectedNumber,
            onNumberSelected: _onNumberSelected,
          ),

          const SizedBox(height: 16),

          _buildPaperDivider(),

          const SizedBox(height: 12),

          ...level.clues.map((clue) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClueCard(
                clue: clue,
                userGuesses: provider.userInputs,
                cipherMap: provider.cipherMap,
                selectedNumber: _selectedNumber,
                onNumberSelected: _onNumberSelected,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStrikes(int errorsCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          bool isError = index < errorsCount;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isError ? Icons.close_rounded : Icons.favorite_rounded,
              color: Colors.red,
              size: 28,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPaperDivider() {
    return Row(
      children: List.generate(18, (index) {
        return Expanded(
          child: Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: index.isEven
                  ? const Color(0xfffff8df)
                  : const Color(0xfff1e7bd),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHintButton(GameProvider provider) {
    String timerText = '';
    if (provider.hintCount < 3) {
      final secs = provider.secondsUntilNextHint;
      final m = (secs ~/ 60).toString().padLeft(2, '0');
      final s = (secs % 60).toString().padLeft(2, '0');
      timerText = '$m:$s';
    }

    return GestureDetector(
      onTap: () {
        provider.useHint();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xff1597f5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: const Icon(Icons.lightbulb, color: Colors.white, size: 28),
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200, width: 1.5),
                  ),
                  child: Text(
                    '${provider.hintCount}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (provider.hintCount < 3)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                timerText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}