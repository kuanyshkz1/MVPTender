import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({super.key});

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  late TextEditingController _keywordController;
  late TextEditingController _binController;
  bool isPremium = false;

  final List<String> _types = [
    'Все',
    'Запрос ценовых предложений',
    'Открытый конкурс',
    'Аукцион',
    'Из одного источника',
  ];

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController();
    _binController = TextEditingController();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _binController.dispose();
    super.dispose();
  }

  void _addKeyword() {
    if (_keywordController.text.isEmpty) return;
    final filters = ref.read(filterProvider);
    if (!isPremium && filters.keywords.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Лимит 5 слов в бесплатной версии!')),
      );
      return;
    }
    ref.read(filterProvider.notifier).updateKeywords([
      ...filters.keywords,
      _keywordController.text,
    ]);
    _keywordController.clear();
  }

  void _removeKeyword(String keyword) {
    final filters = ref.read(filterProvider);
    final updated = filters.keywords.where((k) => k != keyword).toList();
    ref.read(filterProvider.notifier).updateKeywords(updated);
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final filters = ref.read(filterProvider);
      if (isStart) {
        ref
            .read(filterProvider.notifier)
            .updateDateRange(picked, filters.endDate);
      } else {
        ref
            .read(filterProvider.notifier)
            .updateDateRange(filters.startDate, picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(filterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Фильтры',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => ref.read(filterProvider.notifier).reset(),
            child: const Text(
              'Сбросить',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildSectionTitle('БИН Заказчика'),
          const SizedBox(height: 8),
          TextField(
            controller: _binController,
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                ref.read(filterProvider.notifier).updateBin(value),
            decoration: _modernInputDecoration('12 цифр', Icons.tag_rounded),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Ключевые слова (до 5)'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(
                      hintText: 'Например: ремонт, вода',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addKeyword,
                  icon: const Icon(
                    Icons.add_circle_rounded,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (filters.keywords.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filters.keywords
                  .map(
                    (w) => Chip(
                      label: Text(
                        w,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: const Color(0xFFEFF6FF),
                      side: BorderSide.none,
                      deleteIconColor: const Color(0xFF3B82F6),
                      onDeleted: () => _removeKeyword(w),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 32),

          _buildSectionTitle('Бюджет закупки (₸)'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filters.priceRange.start.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ')} ₸',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      '${filters.priceRange.end.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ')} ₸',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: filters.priceRange,
                  min: 0,
                  max: 100000000,
                  divisions: 100,
                  activeColor: const Color(0xFF2563EB),
                  inactiveColor: const Color(0xFFE2E8F0),
                  onChanged: (values) => ref
                      .read(filterProvider.notifier)
                      .updatePriceRange(values),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Тип закупки'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: filters.selectedType,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF64748B),
                ),
                items: _types
                    .map(
                      (val) => DropdownMenuItem(
                        value: val,
                        child: Text(
                          val,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) =>
                    ref.read(filterProvider.notifier).updateType(val!),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Период публикации'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(true),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          filters.startDate == null
                              ? 'С даты'
                              : '${filters.startDate!.day}.${filters.startDate!.month}',
                          style: TextStyle(
                            color: filters.startDate == null
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(false),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          filters.endDate == null
                              ? 'По дату'
                              : '${filters.endDate!.day}.${filters.endDate!.month}',
                          style: TextStyle(
                            color: filters.endDate == null
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),

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
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Показать результаты',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _modernInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
    );
  }
}
