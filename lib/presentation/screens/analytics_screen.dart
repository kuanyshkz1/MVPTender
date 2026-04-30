import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/saved_tender.dart';
import '../providers/notes_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Аналитика',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Не удалось загрузить аналитику: $err',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return const _EmptyAnalyticsState();
          }

          final totalBudget = notes.fold<double>(
            0,
            (sum, note) => sum + note.price,
          );
          final notesWithComment = notes
              .where((note) => note.noteText.trim().isNotEmpty)
              .length;
          final groupedByType = _groupByType(notes);
          final topNotes = [...notes]
            ..sort((a, b) => b.price.compareTo(a.price));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Сохранено лотов',
                      value: '${notes.length}',
                      color: const Color(0xFF2563EB),
                      icon: Icons.bookmark_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: 'С заметками',
                      value: '$notesWithComment',
                      color: const Color(0xFF0F766E),
                      icon: Icons.sticky_note_2_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _MetricCard(
                title: 'Общая сумма потенциальных контрактов',
                value: '${_formatAmount(totalBudget)} ₸',
                color: const Color(0xFFF59E0B),
                icon: Icons.payments_rounded,
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Распределение по типам закупок',
                subtitle: 'Круговая диаграмма по сохранённым лотам',
                child: SizedBox(
                  height: 240,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            centerSpaceRadius: 44,
                            sectionsSpace: 3,
                            pieTouchData: PieTouchData(enabled: false),
                            sections: _buildPieSections(groupedByType),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: groupedByType.entries.toList().asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final typeEntry = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _LegendItem(
                                color: _chartColors[index % _chartColors.length],
                                label: typeEntry.key,
                                value: '${typeEntry.value}',
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Топ сохранённых лотов по сумме',
                subtitle: 'Показывает самые крупные сохранённые контракты',
                child: SizedBox(
                  height: 260,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: topNotes.take(5).fold<double>(
                            0,
                            (maxValue, note) =>
                                note.price > maxValue ? note.price : maxValue,
                          ) *
                          1.2,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: totalBudget > 0 ? totalBudget / 4 : 1,
                        getDrawingHorizontalLine: (value) => const FlLine(
                          color: Color(0xFFE2E8F0),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 52,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                _compactAmount(value),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              final displayed = topNotes.take(5).toList();
                              if (index < 0 || index >= displayed.length) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _shortNumber(displayed[index].tenderNumber),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: topNotes.take(5).toList().asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final note = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: note.price,
                              width: 22,
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF60A5FA),
                                  Color(0xFF2563EB),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Сохранённые лоты',
                subtitle: 'Краткая сводка по каждому сохранённому тендеру',
                child: Column(
                  children: topNotes.take(5).map((note) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SavedLotTile(note: note),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, int> _groupByType(List<SavedTender> notes) {
    final result = <String, int>{};
    for (final note in notes) {
      final type = note.type.trim().isEmpty ? 'Без типа' : note.type.trim();
      result[type] = (result[type] ?? 0) + 1;
    }
    return result;
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> groupedByType) {
    final total = groupedByType.values.fold<int>(0, (sum, count) => sum + count);

    return groupedByType.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final typeEntry = entry.value;
      final percent = total == 0 ? 0.0 : (typeEntry.value / total) * 100;

      return PieChartSectionData(
        value: typeEntry.value.toDouble(),
        title: '${percent.toStringAsFixed(0)}%',
        color: _chartColors[index % _chartColors.length],
        radius: 58,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      );
    }).toList();
  }
}

class _EmptyAnalyticsState extends StatelessWidget {
  const _EmptyAnalyticsState();

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
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.insights_rounded,
                size: 42,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Пока нет данных для аналитики',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Сохрани несколько тендеров в избранное, и здесь появятся диаграммы и сводка по суммам.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 6),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SavedLotTile extends StatelessWidget {
  final SavedTender note;

  const _SavedLotTile({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note.tenderNumber,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_formatAmount(note.price)} ₸',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatAmount(num value) {
  return value
      .toInt()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ');
}

String _compactAmount(double value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}K';
  }
  return value.toInt().toString();
}

String _shortNumber(String number) {
  if (number.length <= 6) return number;
  return number.substring(number.length - 6);
}

const List<Color> _chartColors = [
  Color(0xFF2563EB),
  Color(0xFF0F766E),
  Color(0xFFF59E0B),
  Color(0xFFDC2626),
  Color(0xFF7C3AED),
];
