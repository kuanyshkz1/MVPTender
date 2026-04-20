import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final List<String> _keywords = [];
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _binController = TextEditingController();
  
  RangeValues _priceRange = const RangeValues(0, 50000000);
  String _selectedType = 'Все';
  DateTime? _startDate;
  DateTime? _endDate;
  bool isPremium = false; 

  final List<String> _types = ['Все', 'Запрос ценовых предложений', 'Открытый конкурс', 'Аукцион', 'Из одного источника'];

  void _addKeyword() {
    if (_keywordController.text.isEmpty) return;
    if (!isPremium && _keywords.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Лимит 5 слов в бесплатной версии!')));
      return;
    }
    setState(() {
      _keywords.add(_keywordController.text);
      _keywordController.clear();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Фильтры поиска')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('БИН Заказчика', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _binController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '12 цифр')),
          const SizedBox(height: 20),
          
          const Text('Ключевые слова (до 5)', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(child: TextField(controller: _keywordController, decoration: const InputDecoration(hintText: 'Например: ремонт, мебель'))),
              IconButton(onPressed: _addKeyword, icon: const Icon(Icons.add_circle, color: Colors.blue)),
            ],
          ),
          Wrap(spacing: 8, children: _keywords.map((w) => Chip(label: Text(w), onDeleted: () => setState(() => _keywords.remove(w)))).toList()),
          const Divider(height: 40),

          Text('Цена: от ${_priceRange.start.toInt()} до ${_priceRange.end.toInt()} ₸', style: const TextStyle(fontWeight: FontWeight.bold)),
          RangeSlider(values: _priceRange, min: 0, max: 100000000, divisions: 100, onChanged: (values) => setState(() => _priceRange = values)),
          const SizedBox(height: 20),

          const Text('Тип закупки:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _selectedType, isExpanded: true,
            items: _types.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
            onChanged: (val) => setState(() => _selectedType = val!),
          ),
          const SizedBox(height: 20),

          const Text('Период закупки', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => _selectDate(context, true), child: Text(_startDate == null ? 'С даты' : '${_startDate!.day}.${_startDate!.month}'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton(onPressed: () => _selectDate(context, false), child: Text(_endDate == null ? 'По дату' : '${_endDate!.day}.${_endDate!.month}'))),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.blue, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context), 
            child: const Text('Применить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}