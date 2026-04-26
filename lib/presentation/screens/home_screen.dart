import 'dart:async';
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
  Timer? _debounce;
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Настройка карточки',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildToggle('Номер объявления', showNumber, (val) {
                    setModalState(() => showNumber = val);
                    setState(() {});
                  }),
                  _buildToggle('Наименование', showTitle, (val) {
                    setModalState(() => showTitle = val);
                    setState(() {});
                  }),
                  _buildToggle('Заказчик', showCustomer, (val) {
                    setModalState(() => showCustomer = val);
                    setState(() {});
                  }),
                  _buildToggle('Бюджет', showPrice, (val) {
                    setModalState(() => showPrice = val);
                    setState(() {});
                  }),
                  _buildToggle('Статус', showStatus, (val) {
                    setModalState(() => showStatus = val);
                    setState(() {});
                  }),
                  _buildToggle('Сроки', showEndDate, (val) {
                    setModalState(() => showEndDate = val);
                    setState(() {});
                  }),
                ],
              ),
            );
          },
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
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tendersAsync = ref.watch(tendersProvider);
    final filteredTenders = ref.watch(filteredTendersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern background color
      appBar: AppBar(
        title: const Text(
          'QazTender',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF2563EB),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.dashboard_customize_outlined,
              color: Color(0xFF64748B),
            ),
            onPressed: _showCardSettings,
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Color(0xFF2563EB)),
            onPressed: () => context.push('/filters'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    ref.read(searchQueryProvider.notifier).state = query;
                  });
                  setState(() {});
                },
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Поиск по лотам...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF64748B),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF64748B),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
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
              data: (_) {
                final List<Tender> displayedTenders = filteredTenders;

                final itemsToShow = isPremium
                    ? displayedTenders.length
                    : (displayedTenders.length > 25
                          ? 25
                          : displayedTenders.length);

                if (displayedTenders.isEmpty) {
                  return const Center(
                    child: Text(
                      'Ничего не найдено',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: itemsToShow,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tender = displayedTenders[index];
                    final bool isActive = tender.status == 'Прием заявок';
                    final Color statusColor = isActive
                        ? Colors.green
                        : Colors.grey;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            offset: Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (showNumber)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            tender.number,
                                            style: const TextStyle(
                                              color: Color(0xFF2563EB),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      if (showNumber && showTitle)
                                        const SizedBox(height: 10),
                                      if (showTitle)
                                        Text(
                                          tender.title,
                                          style: const TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      if (showTitle && showCustomer)
                                        const SizedBox(height: 8),
                                      if (showCustomer)
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.business_rounded,
                                              size: 14,
                                              color: Color(0xFF94A3B8),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${tender.customer} (БИН: ${tender.bin})',
                                                style: const TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      if ((showTitle || showCustomer) &&
                                          showStatus)
                                        const SizedBox(height: 12),
                                      if (showStatus)
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: statusColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              tender.status,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (showPrice)
                                      Text(
                                        '${tender.price.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ')} ₸',
                                        style: const TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    if (showEndDate) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'до ${tender.endDate.day.toString().padLeft(2, '0')}.${tender.endDate.month.toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFF8FAFC),
                                  foregroundColor: const Color(0xFF2563EB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () => context.push(
                                  '/home/details',
                                  extra: tender,
                                ),
                                child: const Text(
                                  'Подробнее о тендере',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
