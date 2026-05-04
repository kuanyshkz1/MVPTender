import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Object _unset = Object();

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
    Object? bin = _unset,
    RangeValues? priceRange,
    String? selectedType,
    Object? startDate = _unset,
    Object? endDate = _unset,
  }) {
    final nextBin = identical(bin, _unset) ? this.bin : bin as String?;
    final nextStartDate = identical(startDate, _unset)
        ? this.startDate
        : startDate as DateTime?;
    final nextEndDate =
        identical(endDate, _unset) ? this.endDate : endDate as DateTime?;

    return FilterState(
      keywords: keywords ?? this.keywords,
      bin: nextBin,
      priceRange: priceRange ?? this.priceRange,
      selectedType: selectedType ?? this.selectedType,
      startDate: nextStartDate,
      endDate: nextEndDate,
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
    final trimmed = bin.trim();
    state = state.copyWith(bin: trimmed.isEmpty ? null : trimmed);
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
