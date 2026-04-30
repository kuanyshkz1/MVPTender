import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
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
