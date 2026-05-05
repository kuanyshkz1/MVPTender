import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_formatters.dart';
import '../providers/filter_providers.dart';

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
    final filters = ref.read(filterProvider);
    _keywordController = TextEditingController();
    _binController = TextEditingController(text: filters.bin ?? '');
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _binController.dispose();
    super.dispose();
  }

  void _addKeyword() {
    final keyword = _keywordController.text.trim();
    if (keyword.isEmpty) return;

    final filters = ref.read(filterProvider);
    final alreadyExists = filters.keywords.any(
      (item) => item.toLowerCase() == keyword.toLowerCase(),
    );

    if (alreadyExists) {
      _showSnack('Это ключевое слово уже добавлено');
      return;
    }

    if (!isPremium && filters.keywords.length >= 5) {
      _showSnack('Лимит 5 слов в бесплатной версии');
      return;
    }

    ref.read(filterProvider.notifier).updateKeywords([
      ...filters.keywords,
      keyword,
    ]);
    _keywordController.clear();
  }

  void _removeKeyword(String keyword) {
    final filters = ref.read(filterProvider);
    final updated = filters.keywords.where((k) => k != keyword).toList();
    ref.read(filterProvider.notifier).updateKeywords(updated);
  }

  Future<void> _selectDate(bool isStart) async {
    final filters = ref.read(filterProvider);
    final initialDate = isStart
        ? filters.startDate ?? DateTime.now()
        : filters.endDate ?? filters.startDate ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked == null) return;

    if (isStart) {
      final shouldClearEnd =
          filters.endDate != null && filters.endDate!.isBefore(picked);
      ref
          .read(filterProvider.notifier)
          .updateDateRange(picked, shouldClearEnd ? null : filters.endDate);
    } else {
      final shouldClearStart =
          filters.startDate != null && filters.startDate!.isAfter(picked);
      ref
          .read(filterProvider.notifier)
          .updateDateRange(shouldClearStart ? null : filters.startDate, picked);
    }
  }

  void _resetFilters() {
    ref.read(filterProvider.notifier).reset();
    _binController.clear();
    _keywordController.clear();
  }

  void _clearDates() {
    ref.read(filterProvider.notifier).updateDateRange(null, null);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(filterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Фильтры',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Сбросить'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _FilterSection(
            title: 'Заказчик',
            subtitle: 'Поиск по БИН организации',
            child: TextField(
              controller: _binController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              onChanged: (value) =>
                  ref.read(filterProvider.notifier).updateBin(value),
              decoration: const InputDecoration(
                hintText: '12 цифр',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _FilterSection(
            title: 'Ключевые слова',
            subtitle: '${filters.keywords.length}/5 в бесплатной версии',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _keywordController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addKeyword(),
                        decoration: const InputDecoration(
                          hintText: 'Например: ремонт, вода',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: _addKeyword,
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Добавить слово',
                    ),
                  ],
                ),
                if (filters.keywords.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filters.keywords
                        .map(
                          (word) => InputChip(
                            label: Text(word),
                            onDeleted: () => _removeKeyword(word),
                            deleteIcon: const Icon(
                              Icons.close_rounded,
                              size: 16,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FilterSection(
            title: 'Бюджет закупки',
            subtitle: 'Диапазон суммы в тенге',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _AmountPill(
                        label: 'От',
                        value: AppFormatters.money(filters.priceRange.start),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AmountPill(
                        label: 'До',
                        value: AppFormatters.money(filters.priceRange.end),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RangeSlider(
                  values: filters.priceRange,
                  min: 0,
                  max: 100000000,
                  divisions: 100,
                  labels: RangeLabels(
                    AppFormatters.compactAmount(filters.priceRange.start),
                    AppFormatters.compactAmount(filters.priceRange.end),
                  ),
                  onChanged: (values) => ref
                      .read(filterProvider.notifier)
                      .updatePriceRange(values),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FilterSection(
            title: 'Тип закупки',
            subtitle: 'Выберите способ проведения',
            child: DropdownButtonFormField<String>(
              initialValue: filters.selectedType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_rounded),
              ),
              items: _types
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                ref.read(filterProvider.notifier).updateType(value);
              },
            ),
          ),
          const SizedBox(height: 14),
          _FilterSection(
            title: 'Период публикации',
            subtitle: 'Ограничьте дату окончания приема',
            trailing: filters.startDate != null || filters.endDate != null
                ? TextButton(
                    onPressed: _clearDates,
                    child: const Text('Очистить'),
                  )
                : null,
            child: Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: 'С даты',
                    value: filters.startDate == null
                        ? null
                        : AppFormatters.date(filters.startDate!),
                    onTap: () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateTile(
                    label: 'По дату',
                    value: filters.endDate == null
                        ? null
                        : AppFormatters.date(filters.endDate!),
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Показать результаты'),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  const _FilterSection({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AmountPill extends StatelessWidget {
  final String label;
  final String value;

  const _AmountPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value ?? 'Не выбрано',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: value == null
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
