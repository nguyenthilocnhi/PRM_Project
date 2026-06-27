import 'package:flutter/material.dart';

class PuzzleWordView extends StatelessWidget {
  final List<String> lines;
  final Map<int, String> userGuesses;
  final Map<String, int> cipherMap;
  final int? selectedNumber;
  final Function(int) onNumberSelected;

  const PuzzleWordView({
    super.key,
    required this.lines,
    required this.userGuesses,
    required this.cipherMap,
    required this.selectedNumber,
    required this.onNumberSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: lines.map((line) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 10,
            children: line.split(' ').map((word) {
              return Wrap(
                spacing: 5,
                runSpacing: 5,
                children: word.split('').map((letter) {
                  final number = cipherMap[letter];
                  if (number == null) {
                    return Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () => onNumberSelected(number),
                    child: _PuzzleLetterCell(
                      letter: userGuesses[number] ?? '',
                      number: number,
                      isSelected: selectedNumber == number,
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _PuzzleLetterCell extends StatelessWidget {
  final String letter;
  final int number;
  final bool isSelected;

  const _PuzzleLetterCell({
    required this.letter,
    required this.number,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: Column(
        children: [
          Container(
            width: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.yellow.withValues(alpha: 0.3) : Colors.transparent,
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
            width: 21,
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
