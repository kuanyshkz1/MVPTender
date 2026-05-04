import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/tender_model.dart';
import '../data/models/tender_note.dart';
import '../domain/repositories/notes_repository_impl.dart';

// ==========================================
// FILTER STATE (Фильтры)
// ==========================================
class FilterState {
  final List<String> keywords;
  final String? bin;
  final RangeValues priceRange;
  final String selectedType;
  final DateTime? startDate;
  final DateTime? endDate;

  FilterState({
    this.keywords = const [],
    this.bin,
    this.priceRange = const RangeValues(0, 50000000),
    this.selectedType = 'Все',
    this.startDate,
    this.endDate,
  });

  FilterState copyWith({
    List<String>? keywords,
    String? bin,
    RangeValues? priceRange,
    String? selectedType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return FilterState(
      keywords: keywords ?? this.keywords,
      bin: bin ?? this.bin,
      priceRange: priceRange ?? this.priceRange,
      selectedType: selectedType ?? this.selectedType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// ==========================================
// PROVIDERS
// ==========================================

// Провайдер для фильтров
final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((
  ref,
) {
  return FilterNotifier();
});

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState());

  void updateKeywords(List<String> keywords) {
    state = state.copyWith(keywords: keywords);
  }

  void updateBin(String bin) {
    state = state.copyWith(bin: bin.isEmpty ? null : bin);
  }

  void updatePriceRange(RangeValues range) {
    state = state.copyWith(priceRange: range);
  }

  void updateType(String type) {
    state = state.copyWith(selectedType: type);
  }

  void updateDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void reset() {
    state = FilterState();
  }
}

// Провайдер для строки поиска
final searchQueryProvider = StateProvider<String>((ref) => '');

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

// Провайдер для загрузки тендеров из API
final tendersProvider = FutureProvider<List<TenderModel>>((ref) async {
  const token = 'b938eae8eea4060e2d19e483bec28a30';
  final searchQuery = ref.watch(searchQueryProvider);
  final dio = ref.watch(dioProvider);

  String filterString = '';
  if (searchQuery.isNotEmpty) {
    filterString = ', filter: { nameRu: "*$searchQuery*" }';
  }

  final query = {
    "query":
        "query { TrdBuy(limit: 25$filterString) { id nameRu numberAnno totalSum orgNameRu orgBin refBuyStatusId endDate } }",
  };

  try {
    final response = await dio.post<Map<String, dynamic>>(
      'https://ows.goszakup.gov.kz/v3/graphql',
      data: query,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;

      if (data == null) {
        throw Exception('Empty response from API');
      }

      if (data.containsKey('errors')) {
        throw Exception('GraphQL Error: ${data['errors']}');
      }

      if (data['data'] != null && data['data']['TrdBuy'] != null) {
        final List<dynamic> lotsJson = data['data']['TrdBuy'];
        return lotsJson.map((json) => TenderModel.fromJson(json)).toList();
      } else {
        throw Exception('Empty response from API');
      }
    }

    throw Exception('Server Error: ${response.statusCode}');
  } catch (e) {
    throw Exception('Failed to fetch tenders: $e');
  }
});

// Провайдер для фильтрованных тендеров
final filteredTendersProvider = Provider<List<TenderModel>>((ref) {
  final tendersAsync = ref.watch(tendersProvider);
  final filters = ref.watch(filterProvider);

  return tendersAsync.when(
    data: (tenders) {
      // Применяем фильтры
      return tenders.where((tender) {
        // Фильтр по БИН
        if (filters.bin != null && !tender.bin.contains(filters.bin!)) {
          return false;
        }

        // Фильтр по ключевым словам
        if (filters.keywords.isNotEmpty) {
          final matchesKeyword = filters.keywords.any(
            (keyword) =>
                tender.title.toLowerCase().contains(keyword.toLowerCase()) ||
                tender.customer.toLowerCase().contains(keyword.toLowerCase()),
          );
          if (!matchesKeyword) return false;
        }

        // Фильтр по цене
        if (tender.price < filters.priceRange.start ||
            tender.price > filters.priceRange.end) {
          return false;
        }

        // Фильтр по типу
        if (filters.selectedType != 'Все' &&
            tender.type != filters.selectedType) {
          return false;
        }

        // Фильтр по датам
        if (filters.startDate != null &&
            tender.endDate.isBefore(filters.startDate!)) {
          return false;
        }
        if (filters.endDate != null &&
            tender.endDate.isAfter(filters.endDate!)) {
          return false;
        }

        return true;
      }).toList();
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});

// Провайдер для заметок/избранных тендеров
final notesRepositoryProvider = Provider<NotesRepositoryImpl>((ref) {
  return NotesRepositoryImpl();
});

final notesProvider = FutureProvider<List<TenderNote>>((ref) async {
  final repository = ref.watch(notesRepositoryProvider);
  return repository.getAllNotes();
});

// Провайдер для сохранения заметки
final saveNoteFamilyProvider = FutureProvider.family<void, TenderNote>((
  ref,
  note,
) async {
  final repository = ref.watch(notesRepositoryProvider);
  await repository.saveNote(note);
  // Обновляем список заметок
  ref.invalidate(notesProvider);
});

// Провайдер для удаления заметки
final deleteNoteFamilyProvider = FutureProvider.family<void, String>((
  ref,
  tenderNumber,
) async {
  final repository = ref.watch(notesRepositoryProvider);
  await repository.deleteNote(tenderNumber);
  // Обновляем список заметок
  ref.invalidate(notesProvider);
});
