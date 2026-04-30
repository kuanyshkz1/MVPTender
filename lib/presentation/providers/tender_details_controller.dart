import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/saved_tender.dart';
import '../../domain/entities/tender.dart';
import 'notes_providers.dart';

final tenderDetailsControllerProvider = Provider<TenderDetailsController>((ref) {
  return TenderDetailsController(ref);
});

class TenderDetailsController {
  final Ref _ref;

  TenderDetailsController(this._ref);

  Future<void> toggleFavorite({
    required Tender tender,
    required bool isFavorite,
    required String noteText,
  }) async {
    if (isFavorite) {
      await _ref.read(deleteNoteFamilyProvider(tender.number).future);
      return;
    }

    final note = SavedTender(
      tenderNumber: tender.number,
      title: tender.title,
      noteText: noteText,
      price: tender.price,
      type: tender.type,
    );

    await _ref.read(saveNoteFamilyProvider(note).future);
  }

  Future<void> saveNote({
    required Tender tender,
    required String noteText,
  }) async {
    final note = SavedTender(
      tenderNumber: tender.number,
      title: tender.title,
      noteText: noteText,
      price: tender.price,
      type: tender.type,
    );

    await _ref.read(saveNoteFamilyProvider(note).future);
  }
}
