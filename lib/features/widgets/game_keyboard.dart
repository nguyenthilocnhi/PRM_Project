import 'package:flutter/material.dart';

class GameKeyboard extends StatelessWidget {
  final Set<String> usedLetters;
  final List<String> disabledLetters;
  final Function(String) onKeyTap;
  final VoidCallback onLeftArrow;
  final VoidCallback onRightArrow;

  const GameKeyboard({
    super.key,
    required this.usedLetters,
    required this.disabledLetters,
    required this.onKeyTap,
    required this.onLeftArrow,
    required this.onRightArrow,
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
                  if (rowIndex == 1) const Spacer(flex: 5),
                  if (rowIndex == 2) _arrowKey(Icons.skip_previous, onLeftArrow),
                  ...row.split('').map((letter) {
                    final bool isUsed = usedLetters.contains(letter);
                    final bool isDisabled = disabledLetters.contains(letter);
                    final bool isActuallyDisabled = isDisabled || isUsed;

                    return Expanded(
                      flex: 10,
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
                  if (rowIndex == 2) _arrowKey(Icons.skip_next, onRightArrow),
                  if (rowIndex == 1) const Spacer(flex: 5),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _arrowKey(IconData icon, VoidCallback onTap) {
    return Expanded(
      flex: 15,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.black87, size: 24),
        ),
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
    Color textColor = Colors.black87;
    double elevationOffset = 3.0;

    if (isUsed) {
      backgroundColor = const Color(0xffe6f8ec);
      textColor = const Color(0xff18b82e);
      elevationOffset = 1.0;
    } else if (isDisabled) {
      backgroundColor = const Color(0xffc5cbd1);
      textColor = Colors.grey.shade500;
      elevationOffset = 0.0;
    }

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: elevationOffset > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 1,
                  offset: Offset(0, elevationOffset),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
