import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/features/game/game_provider.dart';
import 'package:project/features/screens/level_complete_screen.dart';
import 'package:project/features/widgets/clue_card.dart';
import 'package:project/features/widgets/game_keyboard.dart';
import 'package:project/features/widgets/puzzle_word_view.dart';

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

  void _onDelete() {
    if (_selectedNumber != null) {
      context.read<GameProvider>().deleteLetter(_selectedNumber!);
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
      backgroundColor: const Color(0xff45b7f5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopHeader(level.title),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                    child: _buildPhoneFrame(context, provider),
                  ),
                ),
              ],
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
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          Expanded(
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.black, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneFrame(BuildContext context, GameProvider provider) {
    final level = provider.currentLevel!;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            color: const Color(0xfffff8df),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildGameContent(provider),
                  ),
                ),
                GameKeyboard(
                  usedLetters: provider.userInputs.values.toSet(),
                  disabledLetters: List<String>.from(level.disabledLetters),
                  onKeyTap: _onKeyTap,
                  onDelete: _onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent(GameProvider provider) {
    final level = provider.currentLevel!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      child: Column(
        children: [
          _buildDifficultyRow(level.difficulty),
          const SizedBox(height: 10),

          _buildStrikes(provider.errorsCount),

          const SizedBox(height: 4),

          const Text(
            'SOLUTION',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
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

          const SizedBox(height: 6),

          _buildBottomTools(provider),
        ],
      ),
    );
  }

  Widget _buildDifficultyRow(String difficulty) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xffedf6ff),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: const Center(
            child: Text(
              'abc',
              style: TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          difficulty,
          style: const TextStyle(
            color: Color(0xff2d4b85),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xfffff1c2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.psychology, color: Colors.pink, size: 24),
              SizedBox(width: 4),
              Text(
                'Challenge',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStrikes(int errorsCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isError = index < errorsCount;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Text(
            '✕',
            style: TextStyle(
              color: isError ? Colors.red : const Color(0xffe1e1e1),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
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

  Widget _buildBottomTools(GameProvider provider) {
    return Row(
      children: [
        _toolButton(
          icon: Icons.card_giftcard,
          color: const Color(0xff18b768),
          badge: '',
        ),
        const Spacer(),
        _toolButton(
          icon: Icons.checklist,
          color: const Color(0xff1597f5),
          badge: '1',
        ),
        const SizedBox(width: 8),
        _toolButton(
          icon: Icons.lightbulb,
          color: const Color(0xff1597f5),
          badge: provider.hintCount.toString(),
          onTap: () {
            provider.useHint();
          },
        ),
      ],
    );
  }

  Widget _toolButton({
    required IconData icon,
    required Color color,
    required String badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
        Container(
          width: 48,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        if (badge.isNotEmpty)
          Positioned(
            right: -3,
            top: -7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}