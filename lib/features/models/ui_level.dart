class UiClue {
  final String clue;
  final String answer;
  final bool isActive;

  const UiClue({
    required this.clue,
    required this.answer,
    this.isActive = false,
  });

  factory UiClue.fromJson(Map<String, dynamic> json) {
    return UiClue(
      clue: json['clue'] ?? '',
      answer: json['answer'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}

class UiLevel {
  final int id;
  final String title;
  final String difficulty;
  final List<String> quoteLines;
  final List<UiClue> clues;
  final Set<String> usedLetters;
  final Set<String> disabledLetters;

  const UiLevel({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.quoteLines,
    required this.clues,
    required this.usedLetters,
    required this.disabledLetters,
  });

  factory UiLevel.fromJson(Map<String, dynamic> json) {
    return UiLevel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      difficulty: json['difficulty'] ?? '',
      quoteLines: List<String>.from(json['quoteLines'] ?? []),
      clues: (json['clues'] as List? ?? [])
          .map((item) => UiClue.fromJson(item))
          .toList(),
      usedLetters: Set<String>.from(json['usedLetters'] ?? []),
      disabledLetters: Set<String>.from(json['disabledLetters'] ?? []),
    );
  }
}