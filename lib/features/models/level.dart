import 'clue.dart';

class Level {
  final int id;
  final String title;
  final String difficulty;
  final List<String> quoteLines;
  final List<Clue> clues;
  final List<String> usedLetters;
  final List<String> disabledLetters;

  Level({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.quoteLines,
    required this.clues,
    required this.usedLetters,
    required this.disabledLetters,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as int,
      title: json['title'] as String,
      difficulty: json['difficulty'] as String,
      quoteLines: List<String>.from(json['quoteLines']),
      clues: (json['clues'] as List).map((c) => Clue.fromJson(c)).toList(),
      usedLetters: List<String>.from(json['usedLetters']),
      disabledLetters: List<String>.from(json['disabledLetters']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'difficulty': difficulty,
      'quoteLines': quoteLines,
      'clues': clues.map((c) => c.toJson()).toList(),
      'usedLetters': usedLetters,
      'disabledLetters': disabledLetters,
    };
  }
}
