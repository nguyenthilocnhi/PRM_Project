import 'package:flutter/material.dart';

class GameKeyboard extends StatelessWidget {
  final Set<String> usedLetters;
  final Set<String> disabledLetters;
  final Function(String) onKeyTap;
  final VoidCallback onDelete;

  const GameKeyboard({
    super.key,
    required this.usedLetters,
    required this.disabledLetters,
    required this.onKeyTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      'QWERTYUIOP',
      'ASDFGHJKL',
      'ZXCVBNM',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
      decoration: const BoxDecoration(
        color: Color(0xffd4d9dd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...rows.asMap().entries.map((entry) {
            final rowIndex = entry.key;
            final row = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (rowIndex == 2) _arrowKey(Icons.keyboard_tab_outlined, () {}),
                  ...row.split('').map((letter) {
                    final bool isUsed = usedLetters.contains(letter);
                    final bool isDisabled = disabledLetters.contains(letter);
                    final bool isActuallyDisabled = isDisabled || isUsed;

                    return Expanded(
                      child: GestureDetector(
                        onTap: isActuallyDisabled ? null : () => onKeyTap(letter),
                        child: _KeyboardKey(
                          letter: letter,
                          isUsed: isUsed,
                          isDisabled: isActuallyDisabled,
                        ),
                      ),
                    );
                  }),
                  if (rowIndex == 2) _arrowKey(Icons.backspace_outlined, onDelete),
                  if (rowIndex == 1) const SizedBox(width: 20), // Balance for 9 keys
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _arrowKey(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 24),
      ),
    );
  }
}

class _KeyboardKey extends StatelessWidget {
  final String letter;
  final bool isUsed;
  final bool isDisabled;

  const _KeyboardKey({
    required this.letter,
    required this.isUsed,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    Color textColor = Colors.black;

    if (isUsed) {
      textColor = const Color(0xff18b82e);
    }

    if (isDisabled) {
      backgroundColor = Colors.grey.shade400;
      textColor = Colors.grey.shade600;
    }

    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
