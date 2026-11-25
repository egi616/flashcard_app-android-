import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../theme/app_color.dart';
import '../widgets/app_button.dart';

class PlayFlashcardScreen extends StatefulWidget {
  const PlayFlashcardScreen({
    required this.title,
    required this.cards,
    super.key,
  });

  final String title;
  final List<Flashcard> cards;

  @override
  State<PlayFlashcardScreen> createState() => _PlayFlashcardScreenState();
}

class _PlayFlashcardScreenState extends State<PlayFlashcardScreen> {
  int _currentIndex = 0;
  final Set<String> _masteredCardIds = {};
  bool _isAnswerVisible = false;
  bool _sessionComplete = false;

  void _moveTo(int index) {
    if (index < 0 || index >= widget.cards.length) return;
    setState(() {
      _currentIndex = index;
      _isAnswerVisible = false;
    });
  }

  void _recordAnswer({required bool mastered}) {
    final card = widget.cards[_currentIndex];
    setState(() {
      if (mastered) {
        _masteredCardIds.add(card.id);
      } else {
        _masteredCardIds.remove(card.id);
      }

      _isAnswerVisible = false;
      if (_currentIndex == widget.cards.length - 1) {
        _sessionComplete = true;
      } else {
        _currentIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const SafeArea(
          top: false,
          child: Center(child: Text('Belum ada kartu untuk dipelajari.')),
        ),
      );
    }

    final card = widget.cards[_currentIndex];
    final masteryProgress = _masteredCardIds.length / widget.cards.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Tutup sesi belajar',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: _sessionComplete
            ? _CompletedState(
                masteredCount: _masteredCardIds.length,
                totalCount: widget.cards.length,
                onClose: () => Navigator.pop(context),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Kartu ${_currentIndex + 1} dari ${widget.cards.length}',
                          style: const TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_masteredCardIds.length} dikuasai',
                          style: const TextStyle(
                            color: AppColor.primaryPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: masteryProgress,
                        minHeight: 5,
                        backgroundColor: AppColor.primaryContainer,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: FlipCardWidget(
                        key: ValueKey(card.id),
                        frontText: card.question,
                        backText: card.answer,
                        onFlipChanged: (showingAnswer) {
                          if (_isAnswerVisible != showingAnswer && mounted) {
                            setState(() => _isAnswerVisible = showingAnswer);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isAnswerVisible)
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Perlu Diulang',
                              expanded: true,
                              warning: true,
                              onPressed: () => _recordAnswer(mastered: false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              label: 'Sudah Paham',
                              expanded: true,
                              icon: Icons.check,
                              onPressed: () => _recordAnswer(mastered: true),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Sebelumnya',
                              icon: Icons.arrow_back,
                              expanded: true,
                              secondary: true,
                              onPressed: _currentIndex == 0
                                  ? null
                                  : () => _moveTo(_currentIndex - 1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              label: 'Selanjutnya',
                              icon: Icons.chevron_right,
                              expanded: true,
                              secondary: true,
                              onPressed:
                                  _currentIndex == widget.cards.length - 1
                                  ? null
                                  : () => _moveTo(_currentIndex + 1),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class FlipCardWidget extends StatefulWidget {
  const FlipCardWidget({
    required this.frontText,
    required this.backText,
    required this.onFlipChanged,
    super.key,
  });

  final String frontText;
  final String backText;
  final ValueChanged<bool> onFlipChanged;

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  void _flipCard() {
    if (_controller.isAnimating) return;
    final showAnswer = !_controller.isCompleted;
    if (showAnswer) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onFlipChanged(showAnswer);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * math.pi;
          final showFront = angle <= math.pi / 2;
          final side = showFront
              ? _CardSide(
                  label: 'PERTANYAAN',
                  text: widget.frontText,
                  instruction: 'Ketuk kartu untuk melihat jawaban',
                )
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: _CardSide(
                    label: 'JAWABAN',
                    text: widget.backText,
                    instruction: 'Ketuk kartu untuk melihat pertanyaan',
                    answerSide: true,
                  ),
                );

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: side,
          );
        },
      ),
    );
  }
}

class _CardSide extends StatelessWidget {
  const _CardSide({
    required this.label,
    required this.text,
    required this.instruction,
    this.answerSide = false,
  });

  final String label;
  final String text;
  final String instruction;
  final bool answerSide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: answerSide ? AppColor.cardBackLilac : AppColor.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: answerSide ? const Color(0xFFC4B5FD) : AppColor.borderSlate,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: answerSide
                      ? AppColor.primaryPurple
                      : AppColor.primaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: answerSide
                        ? AppColor.surfaceWhite
                        : AppColor.primaryPurple,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              const Spacer(),
              if (answerSide)
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColor.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: AppColor.primaryPurple,
                  ),
                ),
            ],
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: answerSide ? 21 : 23,
                    height: 1.4,
                    fontWeight: answerSide ? FontWeight.w600 : FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              instruction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColor.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedState extends StatelessWidget {
  const _CompletedState({
    required this.masteredCount,
    required this.totalCount,
    required this.onClose,
  });

  final int masteredCount;
  final int totalCount;
  final VoidCallback onClose;

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
                Icons.auto_awesome,
                color: AppColor.primaryPurple,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sesi belajar selesai.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColor.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$masteredCount dari $totalCount kartu dikuasai. Sedikit demi sedikit, makin melekat.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColor.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'Kembali ke kategori',
              expanded: true,
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
