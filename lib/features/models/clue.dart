class Clue {
  final String clue;
  final String answer;
  final bool isActive;
  final String? imagePath;

  Clue({
    required this.clue,
    required this.answer,
    required this.isActive,
    this.imagePath,
  });

  factory Clue.fromJson(Map<String, dynamic> json) {
    return Clue(
      clue: json['clue'] as String,
      answer: json['answer'] as String,
      isActive: json['isActive'] as bool? ?? false,
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clue': clue,
      'answer': answer,
      'isActive': isActive,
      if (imagePath != null) 'imagePath': imagePath,
    };
  }
}
