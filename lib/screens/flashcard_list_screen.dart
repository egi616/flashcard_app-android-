import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../models/flashcard.dart';
import '../services/database_service.dart';
import '../theme/app_color.dart';
import '../widgets/app_button.dart';
import '../widgets/app_dialog.dart';
import '../widgets/section_header.dart';
import 'play_flashcard_screen.dart';

class FlashcardListScreen extends StatefulWidget {
  const FlashcardListScreen({
    required this.deck,
    required this.database,
    super.key,
  });

  final Deck deck;
  final DatabaseService database;

  @override
  State<FlashcardListScreen> createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends State<FlashcardListScreen> {
  List<Flashcard> _cards = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final cards = await widget.database.getFlashcards(widget.deck.id);
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Kartu tidak dapat dimuat: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _showCardDialog({Flashcard? card}) async {
    final result = await showDialog<Flashcard>(
      context: context,
      builder: (_) => _FlashcardFormDialog(card: card, deckId: widget.deck.id),
    );
    if (result == null || !mounted) return;

    try {
      if (card == null) {
        await widget.database.addFlashcard(result);
      } else {
        await widget.database.updateFlashcard(result);
      }
      await _loadCards();
      if (mounted) {
        _showMessage(card == null ? 'Kartu ditambahkan.' : 'Kartu diperbarui.');
      }
    } catch (error) {
      if (mounted) _showMessage('Gagal menyimpan kartu: $error');
    }
  }

  Future<void> _deleteCard(Flashcard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus kartu?'),
        content: Text('Kartu "${card.question}" akan dihapus.'),
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
      await widget.database.deleteFlashcard(card.id);
      await _loadCards();
      if (mounted) _showMessage('Kartu dihapus.');
    } catch (error) {
      if (mounted) _showMessage('Gagal menghapus kartu: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _startStudy() {
    if (_cards.isEmpty) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PlayFlashcardScreen(title: widget.deck.title, cards: _cards),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.deck.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Aksi kategori',
            onSelected: (action) {
              if (action == 'refresh') _loadCards();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'refresh', child: Text('Muat ulang')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? _ErrorState(message: _loadError!, onRetry: _loadCards)
            : RefreshIndicator(
                onRefresh: _loadCards,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    const Text(
                      'KOLEKSI / 01',
                      style: TextStyle(
                        color: AppColor.primaryPurple,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.deck.title,
                      style: const TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.deck.description.isEmpty
                          ? 'Koleksi belajar untuk hal-hal yang ingin kamu ingat.'
                          : widget.deck.description,
                      style: const TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(
                          Icons.layers_outlined,
                          size: 17,
                          color: AppColor.primaryPurple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_cards.length} kartu',
                          style: const TextStyle(
                            color: AppColor.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (_cards.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      AppButton(
                        label: 'Mulai Belajar',
                        icon: Icons.play_arrow_rounded,
                        expanded: true,
                        onPressed: _startStudy,
                      ),
                      const SizedBox(height: 28),
                      SectionHeader(
                        title: 'Kartu kamu',
                        trailing: '${_cards.length} kartu',
                      ),
                      ..._cards.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _FlashcardTile(
                            number: entry.key + 1,
                            card: entry.value,
                            onEdit: () => _showCardDialog(card: entry.value),
                            onDelete: () => _deleteCard(entry.value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Menampilkan ${_cards.length} dari ${_cards.length} kartu',
                        style: const TextStyle(
                          color: AppColor.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 36),
                      _EmptyCardsState(onAdd: _showCardDialog),
                    ],
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _cards.isEmpty || _isLoading || _loadError != null
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: const BoxDecoration(
                  color: AppColor.surfaceWhite,
                  border: Border(
                    top: BorderSide(color: AppColor.borderSlate, width: 1),
                  ),
                ),
                child: AppButton(
                  label: 'Tambah Kartu',
                  icon: Icons.add,
                  expanded: true,
                  secondary: true,
                  onPressed: () => _showCardDialog(),
                ),
              ),
            ),
    );
  }
}

class _FlashcardFormDialog extends StatefulWidget {
  const _FlashcardFormDialog({required this.deckId, this.card});

  final String deckId;
  final Flashcard? card;

  @override
  State<_FlashcardFormDialog> createState() => _FlashcardFormDialogState();
}

class _FlashcardFormDialogState extends State<_FlashcardFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _questionController = TextEditingController(
    text: widget.card?.question,
  );
  late final _answerController = TextEditingController(
    text: widget.card?.answer,
  );

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Flashcard(
        id: widget.card?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        deckId: widget.deckId,
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AppDialog(
        title: widget.card == null ? 'Tambah kartu' : 'Edit kartu',
        description: 'Perjelas pertanyaan, permudah mengingat.',
        onSave: _save,
        content: Column(
          children: [
            TextFormField(
              controller: _questionController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Pertanyaan / depan',
                alignLabelWithHint: true,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Pertanyaan wajib diisi.'
                  : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _answerController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Jawaban / belakang',
                alignLabelWithHint: true,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Jawaban wajib diisi.'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashcardTile extends StatelessWidget {
  const _FlashcardTile({
    required this.number,
    required this.card,
    required this.onEdit,
    required this.onDelete,
  });

  final int number;
  final Flashcard card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColor.borderSlate),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                number.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: AppColor.primaryPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.answer,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit kartu',
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                  color: AppColor.textSecondary,
                  icon: const Icon(Icons.edit_outlined, size: 19),
                ),
                IconButton(
                  tooltip: 'Hapus kartu',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                  color: AppColor.destructive,
                  icon: const Icon(Icons.delete_outline, size: 19),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCardsState extends StatelessWidget {
  const _EmptyCardsState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColor.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.copy_all_outlined,
                size: 40,
                color: AppColor.primaryPurple,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Satu pertanyaan.\nBanyak kemungkinan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.textPrimary,
                fontSize: 21,
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tulis pertanyaan di depan,\ndan jawabannya di belakang.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.textSecondary,
                height: 1.5,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 36),
            AppButton(
              label: 'Buat Kartu Pertama',
              icon: Icons.add,
              expanded: true,
              onPressed: onAdd,
            ),
          ],
        ),
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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(label: 'Coba lagi', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
