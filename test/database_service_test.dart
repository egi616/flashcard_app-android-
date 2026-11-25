import 'package:flashcard_app/models/deck.dart';
import 'package:flashcard_app/models/flashcard.dart';
import 'package:flashcard_app/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DatabaseService database;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = DatabaseService();
  });

  test(
    'deck and card changes persist and deleting a deck removes its cards',
    () async {
      const deck = Deck(
        id: 'english',
        title: 'Bahasa Inggris',
        description: 'Kosakata',
      );
      const card = Flashcard(
        id: 'apple',
        deckId: 'english',
        question: 'Apple',
        answer: 'Apel',
      );

      await database.addDeck(deck);
      await database.addFlashcard(card);
      await database.updateDeck(
        const Deck(
          id: 'english',
          title: 'English',
          description: 'Kosakata harian',
        ),
      );
      await database.updateFlashcard(
        const Flashcard(
          id: 'apple',
          deckId: 'english',
          question: 'Apple',
          answer: 'Buah apel',
        ),
      );

      expect((await database.getDecks()).single.title, 'English');
      expect(
        (await database.getFlashcards('english')).single.answer,
        'Buah apel',
      );

      await database.deleteDeck('english');
      expect(await database.getDecks(), isEmpty);
      expect(await database.getFlashcards('english'), isEmpty);
    },
  );
}
