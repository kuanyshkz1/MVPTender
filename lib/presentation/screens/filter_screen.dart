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

  final List<String> _types = ['Все', 'Запрос ценовых предложений', 'Открытый конкурс', 'Аукцион', 'Из одного источника'];

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
        ref.read(filterProvider.notifier).updateDateRange(picked, filters.endDate);
      } else {
        ref.read(filterProvider.notifier).updateDateRange(filters.startDate, picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Фильтры поиска')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('БИН Заказчика', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _binController,
            keyboardType: TextInputType.number,
            onChanged: (value) => ref.read(filterProvider.notifier).updateBin(value),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '12 цифр',
            ),
          ),
          const SizedBox(height: 20),
          const Text('Ключевые слова (до 5)', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keywordController,
                  decoration: const InputDecoration(
                    hintText: 'Например: ремонт, мебель',
                  ),
                ),
              ),
              IconButton(
                onPressed: _addKeyword,
                icon: const Icon(Icons.add_circle, color: Colors.blue),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: filters.keywords
                .map((w) => Chip(
                  label: Text(w),
                  onDeleted: () => _removeKeyword(w),
                ))
                .toList(),
          ),
          const Divider(height: 40),
          Text(
            'Цена: от ${filters.priceRange.start.toInt()} до ${filters.priceRange.end.toInt()} ₸',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: filters.priceRange,
            min: 0,
            max: 100000000,
            divisions: 100,
            onChanged: (values) =>
                ref.read(filterProvider.notifier).updatePriceRange(values),
          ),
          const SizedBox(height: 20),
          const Text('Тип закупки:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: filters.selectedType,
            isExpanded: true,
            items: _types
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
            onChanged: (val) =>
                ref.read(filterProvider.notifier).updateType(val!),
          ),
          const SizedBox(height: 20),
          const Text('Период закупки', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _selectDate(true),
                  child: Text(filters.startDate == null
                      ? 'С даты'
                      : '${filters.startDate!.day}.${filters.startDate!.month}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _selectDate(false),
                  child: Text(filters.endDate == null
                      ? 'По дату'
                      : '${filters.endDate!.day}.${filters.endDate!.month}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Применить',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}