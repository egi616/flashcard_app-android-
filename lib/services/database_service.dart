import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/deck.dart';
import '../models/flashcard.dart';

class DatabaseService {
  static const _decksKey = 'flashcard_decks';
  static const _cardsKey = 'flashcard_cards';

  Future<List<Deck>> getDecks() async {
    final preferences = await SharedPreferences.getInstance();
    final json = preferences.getString(_decksKey);
    if (json == null) return [];

    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded
        .map((item) => Deck.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> addDeck(Deck deck) async {
    final decks = await getDecks();
    await _saveDecks([...decks, deck]);
  }

  Future<void> updateDeck(Deck deck) async {
    final decks = await getDecks();
    final index = decks.indexWhere((item) => item.id == deck.id);
    if (index == -1) throw StateError('Deck tidak ditemukan.');
    decks[index] = deck;
    await _saveDecks(decks);
  }

  Future<void> deleteDeck(String id) async {
    final decks = await getDecks();
    await _saveDecks(decks.where((deck) => deck.id != id).toList());
    final cards = await _getAllCards();
    await _saveCards(cards.where((card) => card.deckId != id).toList());
  }

  Future<List<Flashcard>> getFlashcards(String deckId) async {
    final cards = await _getAllCards();
    return cards.where((card) => card.deckId == deckId).toList();
  }

  Future<void> addFlashcard(Flashcard card) async {
    final cards = await _getAllCards();
    await _saveCards([...cards, card]);
  }

  Future<void> updateFlashcard(Flashcard card) async {
    final cards = await _getAllCards();
    final index = cards.indexWhere((item) => item.id == card.id);
    if (index == -1) throw StateError('Kartu tidak ditemukan.');
    cards[index] = card;
    await _saveCards(cards);
  }

  Future<void> deleteFlashcard(String id) async {
    final cards = await _getAllCards();
    await _saveCards(cards.where((card) => card.id != id).toList());
  }

  Future<List<Flashcard>> _getAllCards() async {
    final preferences = await SharedPreferences.getInstance();
    final json = preferences.getString(_cardsKey);
    if (json == null) return [];

    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded
        .map(
          (item) => Flashcard.fromMap(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<void> _saveDecks(List<Deck> decks) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _decksKey,
      jsonEncode(decks.map((deck) => deck.toMap()).toList()),
    );
    if (!saved) throw StateError('Gagal menyimpan kategori.');
  }

  Future<void> _saveCards(List<Flashcard> cards) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _cardsKey,
      jsonEncode(cards.map((card) => card.toMap()).toList()),
    );
    if (!saved) throw StateError('Gagal menyimpan kartu.');
  }
}
