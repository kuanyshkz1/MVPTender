import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../data/models/tender_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isPremium = false;

  // Настройки видимости элементов карточки
  bool showNumber = true;
  bool showTitle = true;
  bool showCustomer = true;
  bool showPrice = true;
  bool showStatus = true;
  bool showEndDate = true;

  void _showCardSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Настройка карточки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildToggle('Номер объявления', showNumber, (val) { setModalState(() => showNumber = val); setState(() {}); }),
                  _buildToggle('Наименование', showTitle, (val) { setModalState(() => showTitle = val); setState(() {}); }),
                  _buildToggle('Заказчик', showCustomer, (val) { setModalState(() => showCustomer = val); setState(() {}); }),
                  _buildToggle('Бюджет', showPrice, (val) { setModalState(() => showPrice = val); setState(() {}); }),
                  _buildToggle('Статус', showStatus, (val) { setModalState(() => showStatus = val); setState(() {}); }),
                  _buildToggle('Сроки', showEndDate, (val) { setModalState(() => showEndDate = val); setState(() {}); }),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildToggle(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 15)),
      value: value,
      activeThumbColor: Colors.blue,
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tendersAsync = ref.watch(tendersProvider);
    final filteredTenders = ref.watch(filteredTendersProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Tenders KZ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_customize_outlined, color: Colors.blueGrey),
            onPressed: _showCardSettings,
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.blue),
            onPressed: () => context.push('/filters'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                // Поиск по названию и номеру
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Поиск по лотам или номеру',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: tendersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Ошибка: $err'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(tendersProvider),
                      child: const Text('Попробовать снова'),
                    ),
                  ],
                ),
              ),
              data: (allTenders) {
                // Применяем локальный поиск по введенному тексту
                List<Tender> displayedTenders = filteredTenders;
                if (_searchController.text.isNotEmpty) {
                  displayedTenders = displayedTenders
                      .where((tender) =>
                          tender.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                          tender.number.contains(_searchController.text))
                      .toList();
                }

                final itemsToShow = isPremium
                    ? displayedTenders.length
                    : (displayedTenders.length > 25 ? 25 : displayedTenders.length);

                if (displayedTenders.isEmpty) {
                  return const Center(
                    child: Text('Ничего не найдено', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: itemsToShow,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tender = displayedTenders[index];
                    final bool isActive = tender.status == 'Прием заявок';
                    final Color statusColor = isActive ? Colors.green : Colors.grey;

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.push('/home/details', extra: tender),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showNumber)
                                      Text(
                                        tender.number,
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    if (showNumber && showTitle) const SizedBox(height: 4),
                                    if (showTitle)
                                      Text(
                                        tender.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (showTitle && showCustomer) const SizedBox(height: 8),
                                    if (showCustomer)
                                      Text(
                                        '${tender.customer} | БИН: ${tender.bin}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    if ((showTitle || showCustomer) && showStatus)
                                      const SizedBox(height: 12),
                                    if (showStatus)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: statusColor.withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: Text(
                                          tender.status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (showPrice)
                                    Text(
                                      '${tender.price.toInt()} ₸',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                  if (showEndDate) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'до ${tender.endDate.day}.${tender.endDate.month}',
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}