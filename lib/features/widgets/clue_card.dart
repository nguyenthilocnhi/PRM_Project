import 'package:flutter/material.dart';
import '../models/ui_level.dart';

class ClueCard extends StatelessWidget {
  final UiClue clue;
  final Map<int, String> userGuesses;
  final int? selectedNumber;
  final Function(int) onNumberSelected;
  final Map<String, int> cipher;

  const ClueCard({
    super.key,
    required this.clue,
    required this.userGuesses,
    required this.selectedNumber,
    required this.onNumberSelected,
    required this.cipher,
  });

  int _numberFromLetter(String letter) {
    return cipher[letter.toUpperCase()] ?? -1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: clue.isActive ? const Color(0xff28d464) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          if (clue.isActive)
            BoxShadow(
              color: Colors.green.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          Text(
            clue.clue,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 8,
            children: List.generate(clue.answer.length, (index) {
              final letter = clue.answer[index];
              final number = _numberFromLetter(letter);

              return GestureDetector(
                onTap: () => onNumberSelected(number),
                child: _ClueLetterCell(
                  letter: userGuesses[number] ?? '',
                  number: number,
                  isSelected: selectedNumber == number,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ClueLetterCell extends StatelessWidget {
  final String letter;
  final int number;
  final bool isSelected;

  const _ClueLetterCell({
    required this.letter,
    required this.number,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      child: Column(
        children: [
          Container(
            width: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          Container(
            width: 23,
            height: 2,
            margin: const EdgeInsets.only(top: 3),
            color: isSelected ? Colors.blue : Colors.black,
          ),
          const SizedBox(height: 1),
          Text(
            number.toString(),
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.blueGrey,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
