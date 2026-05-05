import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../core/providers/theme_mode_provider.dart';
import '../../domain/entities/tender.dart';
import '../providers/tender_providers.dart';
import '../widgets/tender_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const int _freeLimit = 25;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool isPremium = false;

  bool showNumber = true;
  bool showTitle = true;
  bool showCustomer = true;
  bool showPrice = true;
  bool showStatus = true;
  bool showEndDate = true;

  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).signOut();

    if (!mounted) return;

    context.go('/login');
  }

  void _showCardSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

            return StatefulBuilder(
              builder: (context, setModalState) {
                final colorScheme = Theme.of(context).colorScheme;

                void updateCardSetting(void Function() update) {
                  update();
                  setModalState(() {});
                  setState(() {});
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.dashboard_customize_rounded,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Настройка карточки',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildToggle(
                        context: context,
                        title: 'Темная тема',
                        icon: Icons.dark_mode_rounded,
                        value: isDarkMode,
                        onChanged: (val) {
                          ref.read(themeModeProvider.notifier).toggleTheme(val);
                        },
                      ),
                      const Divider(height: 20),
                      _buildToggle(
                        context: context,
                        title: 'Номер объявления',
                        icon: Icons.tag_rounded,
                        value: showNumber,
                        onChanged: (val) {
                          updateCardSetting(() => showNumber = val);
                        },
                      ),
                      _buildToggle(
                        context: context,
                        title: 'Наименование',
                        icon: Icons.subject_rounded,
                        value: showTitle,
                        onChanged: (val) {
                          updateCardSetting(() => showTitle = val);
                        },
                      ),
                      _buildToggle(
                        context: context,
                        title: 'Заказчик',
                        icon: Icons.business_rounded,
                        value: showCustomer,
                        onChanged: (val) {
                          updateCardSetting(() => showCustomer = val);
                        },
                      ),
                      _buildToggle(
                        context: context,
                        title: 'Бюджет',
                        icon: Icons.payments_rounded,
                        value: showPrice,
                        onChanged: (val) {
                          updateCardSetting(() => showPrice = val);
                        },
                      ),
                      _buildToggle(
                        context: context,
                        title: 'Статус',
                        icon: Icons.task_alt_rounded,
                        value: showStatus,
                        onChanged: (val) {
                          updateCardSetting(() => showStatus = val);
                        },
                      ),
                      _buildToggle(
                        context: context,
                        title: 'Срок подачи',
                        icon: Icons.event_rounded,
                        value: showEndDate,
                        onChanged: (val) {
                          updateCardSetting(() => showEndDate = val);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildToggle({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      value: value,
      activeThumbColor: colorScheme.primary,
      onChanged: onChanged,
    );
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      ref.read(searchQueryProvider.notifier).state = query.trim();
    });
    setState(() {});
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    setState(() {});
  }

  Future<void> _refreshTenders() async {
    return ref.refresh(tendersProvider.future);
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'QazTender',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            tooltip: 'Аналитика',
            onPressed: () => context.push('/analytics'),
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_customize_outlined),
            tooltip: 'Настроить карточки',
            onPressed: _showCardSettings,
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Фильтры',
            onPressed: () => context.push('/filters'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Выйти',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchHeader(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
          ),
          Expanded(
            child: tendersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _StateMessage(
                icon: Icons.cloud_off_rounded,
                title: 'Не удалось загрузить тендеры',
                message: '$err',
                actionLabel: 'Повторить',
                onAction: () => ref.invalidate(tendersProvider),
              ),
              data: (_) {
                final displayedTenders = filteredTenders;
                final itemsToShow = isPremium
                    ? displayedTenders.length
                    : displayedTenders.length > _freeLimit
                    ? _freeLimit
                    : displayedTenders.length;

                if (displayedTenders.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshTenders,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        _StateMessage(
                          icon: Icons.search_off_rounded,
                          title: 'Ничего не найдено',
                          message:
                              'Попробуйте изменить запрос, БИН, бюджет или тип закупки.',
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshTenders,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemCount: itemsToShow + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _ResultsHeader(
                          total: displayedTenders.length,
                          visible: itemsToShow,
                          isLimited:
                              !isPremium &&
                              displayedTenders.length > _freeLimit,
                        );
                      }

                      final Tender tender = displayedTenders[index - 1];
                      return TenderCard(
                        tender: tender,
                        showNumber: showNumber,
                        showTitle: showTitle,
                        showCustomer: showCustomer,
                        showPrice: showPrice,
                        showStatus: showStatus,
                        showEndDate: showEndDate,
                        onTap: () =>
                            context.push('/home/details', extra: tender),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchHeader({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Поиск по лотам, заказчику или БИН',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final int total;
  final int visible;
  final bool isLimited;

  const _ResultsHeader({
    required this.total,
    required this.visible,
    required this.isLimited,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Найдено $total',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              'Показано $visible',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (isLimited) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_open_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'В бесплатной версии показаны первые $visible лотов.',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
