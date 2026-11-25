# Flashcard Edukasi

Aplikasi belajar dengan flashcard untuk mengelompokkan materi ke dalam kategori
dan menghafal pertanyaan beserta jawabannya.

## Fitur

- Membuat, mengubah, dan menghapus kategori belajar.
- Mengelola kartu pertanyaan dan jawaban di setiap kategori.
- Belajar dengan kartu interaktif yang dapat dibalik dan indikator progres.
- Menyimpan kategori dan kartu secara lokal di perangkat.
- Antarmuka monokrom dengan komponen tombol dan dialog yang konsisten.

## Struktur UI

- `lib/theme/app_color.dart` berisi palet warna, ukuran, radius, dan tema aplikasi.
- `lib/widgets/` berisi komponen UI bersama seperti tombol, dialog, dan judul bagian.
- `lib/screens/` berisi layar beranda, koleksi, sesi belajar, dan profil.

## Menjalankan aplikasi

```shell
flutter pub get
flutter run
```

Jalankan pengujian dengan `flutter test`.
