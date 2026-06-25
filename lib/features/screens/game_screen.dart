import 'package:flutter/material.dart';

import 'package:project/features/game/data/level_repository.dart';
import 'package:project/features/models/ui_level.dart';
import 'package:project/features/widgets/clue_card.dart';
import 'package:project/features/widgets/game_keyboard.dart';
import 'package:project/features/widgets/puzzle_word_view.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Future<List<UiLevel>> _levelsFuture;
  final Map<int, String> _userGuesses = {};
  int? _selectedNumber;

  @override
  void initState() {
    super.initState();
    _levelsFuture = LevelRepository().loadLevels();
  }

  void _onNumberSelected(int number) {
    setState(() {
      _selectedNumber = number;
    });
  }

  void _onKeyTap(String letter) {
    if (_selectedNumber != null) {
      setState(() {
        _userGuesses[_selectedNumber!] = letter;
      });
    }
  }

  Set<String> _getUsedLetters() {
    return _userGuesses.values.toSet();
  }

  void _onDelete() {
    if (_selectedNumber != null) {
      setState(() {
        _userGuesses.remove(_selectedNumber!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UiLevel>>(
      future: _levelsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xff45b7f5),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final levels = snapshot.data ?? [];

        if (levels.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('No levels found'),
            ),
          );
        }

        final level = levels.first;

        return Scaffold(
          backgroundColor: const Color(0xff45b7f5),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopHeader(level.title),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                    child: _buildPhoneFrame(context, level),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _buildPhoneFrame(BuildContext context, UiLevel level) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGameContent(level),
                GameKeyboard(
                  usedLetters: _getUsedLetters(),
                  disabledLetters: level.disabledLetters,
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

  Widget _buildGameContent(UiLevel level) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      child: Column(
        children: [
          _buildDifficultyRow(level),
          const SizedBox(height: 10),

          const Text(
            '✕✕✕',
            style: TextStyle(
              color: Color(0xffe1e1e1),
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 6,
            ),
          ),

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
            userGuesses: _userGuesses,
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
                userGuesses: _userGuesses,
                selectedNumber: _selectedNumber,
                onNumberSelected: _onNumberSelected,
              ),
            );
          }),

          const SizedBox(height: 6),

          _buildBottomTools(),
        ],
      ),
    );
  }

  Widget _buildDifficultyRow(UiLevel level) {
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
          level.difficulty,
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

  Widget _buildBottomTools() {
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
          badge: '3',
        ),
      ],
    );
  }

  Widget _toolButton({
    required IconData icon,
    required Color color,
    required String badge,
  }) {
    return Stack(
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
    );
  }
}