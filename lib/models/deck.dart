class Deck {
  const Deck({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
  };

  factory Deck.fromMap(Map<String, dynamic> map) => Deck(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String,
  );
}
