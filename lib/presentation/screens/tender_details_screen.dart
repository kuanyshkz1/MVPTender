import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/saved_tender.dart';
import '../../domain/entities/tender.dart';
import '../providers/notes_providers.dart';
import '../providers/tender_details_controller.dart';

class TenderDetailsScreen extends ConsumerStatefulWidget {
  final Tender tender;
  const TenderDetailsScreen({super.key, required this.tender});

  @override
  ConsumerState<TenderDetailsScreen> createState() =>
      _TenderDetailsScreenState();
}

class _TenderDetailsScreenState extends ConsumerState<TenderDetailsScreen> {
  late TextEditingController _noteController;
  String? _lastSyncedNoteText;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  void _syncNoteText(SavedTender? note) {
    final nextText = note?.noteText ?? '';
    if (_lastSyncedNoteText == nextText) return;

    _lastSyncedNoteText = nextText;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _noteController.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    });
  }

  void _toggleFavorite(bool isFavorite) async {
    final controller = ref.read(tenderDetailsControllerProvider);

    if (isFavorite) {
      await controller.toggleFavorite(
        tender: widget.tender,
        isFavorite: true,
        noteText: _noteController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Удалено из избранного')));
      }
    } else {
      await controller.toggleFavorite(
        tender: widget.tender,
        isFavorite: false,
        noteText: _noteController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Добавлено в избранное')));
      }
    }
  }

  void _saveNote() async {
    final controller = ref.read(tenderDetailsControllerProvider);

    await controller.saveNote(
      tender: widget.tender,
      noteText: _noteController.text,
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заметка сохранена')));
    }
  }

  Future<void> _openUrl() async {
    final url = Uri.parse(
        'https://www.goszakup.gov.kz/ru/announce/index/${widget.tender.number}');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedNote = ref.watch(noteByTenderNumberProvider(widget.tender.number));
    final isFavorite = savedNote != null;
    _syncNoteText(savedNote);

    final bool isActive = widget.tender.status == 'Прием заявок';
    final Color statusColor = isActive
        ? const Color(0xFF10B981)
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Детали лота',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isFavorite
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF94A3B8),
              size: 28,
            ),
            onPressed: () => _toggleFavorite(isFavorite),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    offset: Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.tender.number,
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          widget.tender.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.tender.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 20),
                  _infoRow(
                    'Заказчик',
                    widget.tender.customer,
                    Icons.business_rounded,
                  ),
                  _infoRow('БИН', widget.tender.bin, Icons.tag_rounded),
                  _infoRow(
                    'Окончание приема',
                    '${widget.tender.endDate.day.toString().padLeft(2, '0')}.${widget.tender.endDate.month.toString().padLeft(2, '0')}.${widget.tender.endDate.year}',
                    Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Сумма закупки',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.tender.price.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ')} ₸',
                          style: const TextStyle(
                            fontSize: 28,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: const Color(0xFF2563EB),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final url = Uri.parse('https://www.goszakup.gov.kz/ru/announce/index/${widget.tender.number}');
                await launchUrl(url, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.file_download_outlined),
              label: const Text(
                'Скачать техническую спецификацию',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 12),
              child: Text(
                'Моя заметка',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            TextField(
              controller: _noteController,
              maxLines: 4,
              style: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
              decoration: InputDecoration(
                hintText: 'Добавьте свою заметку...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF475569),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveNote,
              child: const Text(
                'Сохранить заметку',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _openUrl,
              child: const Text(
                'Перейти к источнику',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
