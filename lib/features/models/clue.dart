class Clue {
  final String clue;
  final String answer;
  final bool isActive;

  Clue({
    required this.clue,
    required this.answer,
    required this.isActive,
  });

  factory Clue.fromJson(Map<String, dynamic> json) {
    return Clue(
      clue: json['clue'] as String,
      answer: json['answer'] as String,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clue': clue,
      'answer': answer,
      'isActive': isActive,
    };
  }
}
