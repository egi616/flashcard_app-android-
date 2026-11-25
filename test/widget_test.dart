import 'package:flashcard_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('user can create a deck and study a flashcard', (tester) async {
    await tester.pumpWidget(const FlashcardApp());
    await tester.pumpAndSettle();

    expect(find.text('KARTU PINTAR'), findsOneWidget);
    expect(
      find.text('Pengetahuan besar.\nMulai dari satu kartu.'),
      findsOneWidget,
    );
    expect(find.byType(FilledButton), findsOneWidget);
    await tester.ensureVisible(find.text('Buat Kategori'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat Kategori'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Bahasa Inggris');
    await tester.enterText(find.byType(TextFormField).at(1), 'Kosakata');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Bahasa Inggris'), findsOneWidget);
    await tester.tap(find.text('Bahasa Inggris'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Kartu'), findsNothing);
    await tester.ensureVisible(find.text('Buat Kartu Pertama'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat Kartu Pertama'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Apple');
    await tester.enterText(find.byType(TextFormField).at(1), 'Apel');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Apel'), findsOneWidget);
    await tester.tap(find.text('Mulai Belajar'));
    await tester.pumpAndSettle();

    expect(find.text('Kartu 1 dari 1'), findsOneWidget);
    await tester.tap(find.text('Apple').last);
    await tester.pumpAndSettle();
    expect(find.text('Apel'), findsOneWidget);
    await tester.tap(find.text('Sudah Paham'));
    await tester.pumpAndSettle();
    expect(find.text('Sesi belajar selesai.'), findsOneWidget);
    await tester.tap(find.text('Kembali ke kategori'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Egi Jaelani Febriansyah'));
    await tester.pumpAndSettle();
    expect(find.text('KONTRIBUSI PROYEK'), findsOneWidget);
  });
}
