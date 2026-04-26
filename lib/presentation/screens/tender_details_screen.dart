import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/tender_model.dart';
import '../../data/models/tender_note.dart';
import '../../providers/providers.dart';

class TenderDetailsScreen extends ConsumerStatefulWidget {
  final Tender tender;
  const TenderDetailsScreen({super.key, required this.tender});

  @override
  ConsumerState<TenderDetailsScreen> createState() => _TenderDetailsScreenState();
}

class _TenderDetailsScreenState extends ConsumerState<TenderDetailsScreen> {
  late TextEditingController _noteController;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _checkIfFavorite();
  }

  void _checkIfFavorite() {
    final notes = ref.read(notesProvider);
    notes.whenData((notesList) {
      setState(() {
        _isFavorite = notesList.any((n) => n.tenderNumber == widget.tender.number);
        if (_isFavorite) {
          final note = notesList.firstWhere((n) => n.tenderNumber == widget.tender.number);
          _noteController.text = note.noteText;
        }
      });
    });
  }

  void _toggleFavorite() async {
    if (_isFavorite) {
      // Удаляем из избранного
      await ref.read(deleteNoteFamilyProvider(widget.tender.number).future);
      setState(() => _isFavorite = false);
      _noteController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Удалено из избранного')),
        );
      }
    } else {
      // Добавляем в избранное
      final note = TenderNote(
        tenderNumber: widget.tender.number,
        title: widget.tender.title,
        noteText: _noteController.text,
        price: widget.tender.price,
        type: widget.tender.type,
      );
      await ref.read(saveNoteFamilyProvider(note).future);
      setState(() => _isFavorite = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Добавлено в избранное')),
        );
      }
    }
  }

  void _saveNote() async {
    final note = TenderNote(
      tenderNumber: widget.tender.number,
      title: widget.tender.title,
      noteText: _noteController.text,
      price: widget.tender.price,
      type: widget.tender.type,
    );
    await ref.read(saveNoteFamilyProvider(note).future);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заметка сохранена')),
      );
    }
  }

  Future<void> _openUrl() async {
    final url = 'https://goszakup.gov.kz/ru/announcement/${widget.tender.number}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.tender.status == 'Прием заявок';
    final Color statusColor = isActive ? Colors.green : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали лота'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.tender.type.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    widget.tender.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              widget.tender.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.tender.number,
              style: const TextStyle(color: Colors.blue, fontSize: 16),
            ),
            const SizedBox(height: 20),
            _infoRow('Заказчик:', widget.tender.customer),
            _infoRow('БИН:', widget.tender.bin),
            const Divider(height: 40),
            Text(
              'Сумма закупки:',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              '${widget.tender.price.toInt()} ₸',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _infoRow(
              'Окончание приема заявок:',
              '${widget.tender.endDate.day}.${widget.tender.endDate.month}.${widget.tender.endDate.year}',
            ),
            const SizedBox(height: 30),
            const Text(
              'Моя заметка:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Добавьте свою заметку...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
              onPressed: _saveNote,
              child: const Text('Сохранить заметку'),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _openUrl,
              child: const Text(
                'Перейти к источнику',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}