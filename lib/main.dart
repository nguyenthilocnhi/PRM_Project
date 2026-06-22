import 'package:flutter/material.dart';

void main() {
  runApp(const CryptogramApp());
}

class CryptogramApp extends StatelessWidget {
  const CryptogramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Busters',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const GameScreen(),
    );
  }
}

class ClueItem {
  final String clue;
  final String answer;

  const ClueItem({
    required this.clue,
    required this.answer,
  });
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final String secretQuote = 'DREAM BOLD';

  final List<ClueItem> clues = const [
    ClueItem(clue: 'Not a cat', answer: 'DOG'),
    ClueItem(clue: 'Not big', answer: 'SMALL'),
    ClueItem(clue: 'Not a girl', answer: 'BOY'),
    ClueItem(clue: 'Not happy', answer: 'SAD'),
    ClueItem(clue: 'Not hot', answer: 'COLD'),
    ClueItem(clue: 'Not far', answer: 'NEAR'),
  ];

  final Map<int, String> userAnswers = {};

  int? selectedNumber;
  int mistakes = 0;
  final int maxMistakes = 3;
  bool hasWon = false;

  int numberFromLetter(String letter) {
    return letter.toUpperCase().codeUnitAt(0) - 64;
  }

  String letterFromNumber(int number) {
    return String.fromCharCode(number + 64);
  }

  Set<int> getAllRequiredNumbers() {
    final Set<int> numbers = {};

    for (final char in secretQuote.replaceAll(' ', '').split('')) {
      numbers.add(numberFromLetter(char));
    }

    for (final clue in clues) {
      for (final char in clue.answer.split('')) {
        numbers.add(numberFromLetter(char));
      }
    }

    return numbers;
  }

  void selectNumber(int number) {
    setState(() {
      selectedNumber = number;
    });
  }

  void handleKeyboardPress(String letter) {
    if (selectedNumber == null) {
      showMessage('Choose a box first.');
      return;
    }

    if (mistakes >= maxMistakes || hasWon) {
      return;
    }

    final correctLetter = letterFromNumber(selectedNumber!);

    if (userAnswers[selectedNumber!] == correctLetter) {
      showMessage('This number is already solved.');
      return;
    }

    if (letter == correctLetter) {
      setState(() {
        userAnswers[selectedNumber!] = letter;
      });

      checkWin();
    } else {
      setState(() {
        mistakes++;
      });

      if (mistakes >= maxMistakes) {
        showGameOverDialog();
      } else {
        showMessage('Wrong letter!');
      }
    }
  }

  void useHint() {
    if (mistakes >= maxMistakes || hasWon) {
      return;
    }

    final numbers = getAllRequiredNumbers().toList()..sort();

    for (final number in numbers) {
      final correctLetter = letterFromNumber(number);

      if (userAnswers[number] != correctLetter) {
        setState(() {
          selectedNumber = number;
          userAnswers[number] = correctLetter;
        });

        checkWin();
        return;
      }
    }
  }

  void checkWin() {
    final numbers = getAllRequiredNumbers();

    final isCompleted = numbers.every((number) {
      return userAnswers[number] == letterFromNumber(number);
    });

    if (isCompleted && !hasWon) {
      hasWon = true;
      showWinDialog();
    }
  }

  void resetGame() {
    setState(() {
      userAnswers.clear();
      selectedNumber = null;
      mistakes = 0;
      hasWon = false;
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void showWinDialog() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text('Level Complete 🎉'),
            content: const Text('You solved the code!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  resetGame();
                },
                child: const Text('Play Again'),
              ),
            ],
          );
        },
      );
    });
  }

  void showGameOverDialog() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text('Game Over'),
            content: const Text('You made 3 mistakes. Try again!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  resetGame();
                },
                child: const Text('Reset'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardRows = [
      'QWERTYUIOP',
      'ASDFGHJKL',
      'ZXCVBNM',
    ];

    return Scaffold(
      backgroundColor: const Color(0xff0d3b5c),
      body: SafeArea(
        child: Column(
          children: [
            buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: buildNotebook(),
              ),
            ),
            buildKeyboard(keyboardRows),
          ],
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.pinkAccent),
          const SizedBox(width: 8),
          const Expanded(
            child: Center(
              child: Text(
                'LEVEL 1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: resetGame,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildNotebook() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xfff3d8a3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.orange,
          width: 8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          buildMistakes(),
          const SizedBox(height: 16),

          const Text(
            'Secret Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 14),

          buildSecretQuote(),
          const SizedBox(height: 26),

          const Text(
            'Clues',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 16),

          ...clues.map((item) => buildClueRow(item)),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: useHint,
            icon: const Icon(Icons.lightbulb),
            label: const Text('Hint'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            selectedNumber == null
                ? 'Selected number: none'
                : 'Selected number: $selectedNumber',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMistakes() {
    return Column(
      children: [
        const Text(
          'Mistakes',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxMistakes, (index) {
            final isWrong = index < mistakes;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(
                Icons.close,
                size: 28,
                color: isWrong ? Colors.pink : Colors.grey.shade400,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildSecretQuote() {
    final words = secretQuote.split(' ');

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 14,
      children: words.map((word) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: word.split('').map((letter) {
            return buildLetterBox(letter, boxSize: 34);
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget buildClueRow(ClueItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              item.clue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 5,
              runSpacing: 8,
              children: item.answer.split('').map((letter) {
                return buildLetterBox(letter, boxSize: 36);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLetterBox(String correctLetter, {required double boxSize}) {
    final number = numberFromLetter(correctLetter);
    final userLetter = userAnswers[number] ?? '';
    final isSelected = selectedNumber == number;

    return GestureDetector(
      onTap: () {
        selectNumber(number);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: boxSize,
              height: boxSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade500,
                  width: isSelected ? 3 : 1.5,
                ),
              ),
              child: Text(
                userLetter,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$number',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildKeyboard(List<String> keyboardRows) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
      decoration: const BoxDecoration(
        color: Color(0xffdff5ff),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: keyboardRows.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.split('').map((letter) {
                final number = numberFromLetter(letter);
                final isUsed = userAnswers[number] == letter;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: SizedBox(
                    width: 32,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () {
                        handleKeyboardPress(letter);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor:
                        isUsed ? Colors.green.shade200 : Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}