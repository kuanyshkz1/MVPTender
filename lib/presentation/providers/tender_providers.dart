import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/dependencies_providers.dart';
import '../../domain/entities/tender.dart';
import 'filter_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final tendersProvider = FutureProvider<List<Tender>>((ref) async {
  final searchQuery = ref.watch(searchQueryProvider);
  final repository = ref.watch(tenderRepositoryProvider);
  return repository.fetchTenders(searchQuery: searchQuery);
});

final filteredTendersProvider = Provider<List<Tender>>((ref) {
  final tendersAsync = ref.watch(tendersProvider);
  final filters = ref.watch(filterProvider);

  return tendersAsync.when(
    data: (tenders) {
      return tenders.where((tender) {
        if (filters.bin != null && !tender.bin.contains(filters.bin!)) {
          return false;
        }

        if (filters.keywords.isNotEmpty) {
          final matchesKeyword = filters.keywords.any(
            (keyword) =>
                tender.title.toLowerCase().contains(keyword.toLowerCase()) ||
                tender.customer.toLowerCase().contains(keyword.toLowerCase()),
          );
          if (!matchesKeyword) return false;
        }

        if (tender.price < filters.priceRange.start ||
            tender.price > filters.priceRange.end) {
          return false;
        }

        if (filters.selectedType != 'Все' &&
            tender.type != filters.selectedType) {
          return false;
        }

        if (filters.startDate != null &&
            _dateOnly(tender.endDate).isBefore(_dateOnly(filters.startDate!))) {
          return false;
        }
        if (filters.endDate != null &&
            _dateOnly(tender.endDate).isAfter(_dateOnly(filters.endDate!))) {
          return false;
        }

        return true;
      }).toList();
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
