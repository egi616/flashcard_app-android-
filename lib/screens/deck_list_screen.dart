import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../services/database_service.dart';
import '../theme/app_color.dart';
import '../widgets/app_button.dart';
import '../widgets/app_dialog.dart';
import '../widgets/section_header.dart';
import 'flashcard_list_screen.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  final _database = DatabaseService();
  List<Deck> _decks = [];
  Map<String, int> _cardCounts = {};
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final decks = await _database.getDecks();
      final counts = <String, int>{};
      await Future.wait(
        decks.map((deck) async {
          counts[deck.id] = (await _database.getFlashcards(deck.id)).length;
        }),
      );
      if (!mounted) return;
      setState(() {
        _decks = decks;
        _cardCounts = counts;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Data tidak dapat dimuat: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _showDeckDialog({Deck? deck}) async {
    final result = await showDialog<Deck>(
      context: context,
      builder: (_) => _DeckFormDialog(deck: deck),
    );
    if (result == null || !mounted) return;

    try {
      if (deck == null) {
        await _database.addDeck(result);
      } else {
        await _database.updateDeck(result);
      }
      await _loadDecks();
      if (mounted) {
        _showMessage(
          deck == null ? 'Kategori ditambahkan.' : 'Kategori diperbarui.',
        );
      }
    } catch (error) {
      if (mounted) _showMessage('Gagal menyimpan kategori: $error');
    }
  }

  Future<void> _deleteDeck(Deck deck) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus kategori?'),
        content: Text(
          'Kategori "${deck.title}" dan semua kartu di dalamnya akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColor.destructive,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _database.deleteDeck(deck.id);
      await _loadDecks();
      if (mounted) _showMessage('Kategori dihapus.');
    } catch (error) {
      if (mounted) _showMessage('Gagal menghapus kategori: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openDeck(Deck deck) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardListScreen(deck: deck, database: _database),
      ),
    );
    if (mounted) _loadDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KARTU PINTAR'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColor.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/icons/1.png',
                width: 21,
                height: 21,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? _ErrorState(message: _loadError!, onRetry: _loadDecks)
            : RefreshIndicator(
                onRefresh: _loadDecks,
                child: _decks.isEmpty
                    ? _EmptyDeckState(onAdd: _showDeckDialog)
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                        children: [
                          const Text(
                            'BELAJAR, SATU KARTU SETIAP HARI.',
                            style: TextStyle(
                              color: AppColor.primaryPurple,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Sedikit demi sedikit.\nMakin melekat.',
                            style: TextStyle(
                              color: AppColor.textPrimary,
                              fontSize: 30,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 28),
                          SectionHeader(
                            title: 'Kategori belajar',
                            trailing: _decks.length.toString().padLeft(2, '0'),
                          ),
                          const SizedBox(height: 4),
                          ..._decks.asMap().entries.map((entry) {
                            final deck = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _DeckTile(
                                number: entry.key + 1,
                                deck: deck,
                                cardCount: _cardCounts[deck.id] ?? 0,
                                onTap: () => _openDeck(deck),
                                onEdit: () => _showDeckDialog(deck: deck),
                                onDelete: () => _deleteDeck(deck),
                              ),
                            );
                          }),
                          const SizedBox(height: 88),
                        ],
                      ),
              ),
      ),
      floatingActionButton:
          !_isLoading && _loadError == null && _decks.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showDeckDialog(),
              backgroundColor: AppColor.primaryPurple,
              foregroundColor: AppColor.surfaceWhite,
              icon: const Icon(Icons.add),
              label: const Text('Kategori'),
            )
          : null,
    );
  }
}

class _DeckFormDialog extends StatefulWidget {
  const _DeckFormDialog({this.deck});

  final Deck? deck;

  @override
  State<_DeckFormDialog> createState() => _DeckFormDialogState();
}

class _DeckFormDialogState extends State<_DeckFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(text: widget.deck?.title);
  late final _descriptionController = TextEditingController(
    text: widget.deck?.description,
  );

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Deck(
        id: widget.deck?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AppDialog(
        title: widget.deck == null ? 'Buat kategori' : 'Edit kategori',
        description: 'Kelompokkan hal-hal yang ingin kamu ingat.',
        onSave: _save,
        content: Column(
          children: [
            TextFormField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nama kategori',
                hintText: 'Contoh: Biologi dasar',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nama kategori wajib diisi.'
                  : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Apa yang ingin kamu pelajari?',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({
    required this.number,
    required this.deck,
    required this.cardCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final int number;
  final Deck deck;
  final int cardCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  number.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: AppColor.primaryPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deck.description.isEmpty ? 'Koleksi belajar' : deck.description} · $cardCount kartu',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: cardCount == 0 ? 0 : 1,
                        minHeight: 4,
                        backgroundColor: AppColor.primaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Aksi kategori',
                onSelected: (action) {
                  if (action == 'edit') onEdit();
                  if (action == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit kategori')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus kategori')),
                ],
                icon: const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDeckState extends StatelessWidget {
  const _EmptyDeckState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          const Text(
            'RUANG BELAJARMU',
            style: TextStyle(
              color: AppColor.primaryPurple,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pengetahuan besar.\nMulai dari satu kartu.',
            style: TextStyle(
              color: AppColor.textPrimary,
              fontSize: 30,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Simpan hal penting, lalu pelajari kembali dengan ritmemu sendiri.',
            style: TextStyle(
              color: AppColor.textSecondary,
              height: 1.5,
              fontSize: 14,
            ),
          ),
          SizedBox(height: constraints.maxHeight * 0.03),
          Center(
            child: Container(
              width: 104,
              height: 104,
              decoration: const BoxDecoration(
                color: AppColor.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.copy_all_outlined,
                size: 46,
                color: AppColor.primaryPurple,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Koleksi pertamamu\nmenunggu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColor.textPrimary,
              fontSize: 21,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Buat kategori untuk mengelompokkan\nkartu-kartu yang ingin kamu hafalkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColor.textSecondary,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          SizedBox(height: constraints.maxHeight * 0.04),
          AppButton(
            label: 'Buat Kategori',
            icon: Icons.add,
            expanded: true,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(
              label: 'Coba lagi',
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
