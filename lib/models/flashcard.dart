class Flashcard {
  const Flashcard({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
  });

  final String id;
  final String deckId;
  final String question;
  final String answer;

  Map<String, dynamic> toMap() => {
    'id': id,
    'deckId': deckId,
    'question': question,
    'answer': answer,
  };

  factory Flashcard.fromMap(Map<String, dynamic> map) => Flashcard(
    id: map['id'] as String,
    deckId: map['deckId'] as String,
    question: map['question'] as String,
    answer: map['answer'] as String,
  );
}
