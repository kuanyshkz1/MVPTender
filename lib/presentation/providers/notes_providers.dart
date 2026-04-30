import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/dependencies_providers.dart';
import '../../domain/entities/saved_tender.dart';

final notesProvider = FutureProvider<List<SavedTender>>((ref) async {
  final repository = ref.watch(notesRepositoryProvider);
  return repository.getAllNotes();
});

final noteByTenderNumberProvider = Provider.family<SavedTender?, String>((
  ref,
  tenderNumber,
) {
  final notesAsync = ref.watch(notesProvider);

  return notesAsync.maybeWhen(
    data: (notes) {
      for (final note in notes) {
        if (note.tenderNumber == tenderNumber) {
          return note;
        }
      }
      return null;
    },
    orElse: () => null,
  );
});

final saveNoteFamilyProvider = FutureProvider.family<void, SavedTender>((
  ref,
  note,
) async {
  final repository = ref.watch(notesRepositoryProvider);
  await repository.saveNote(note);
  ref.invalidate(notesProvider);
});

final deleteNoteFamilyProvider = FutureProvider.family<void, String>((
  ref,
  tenderNumber,
) async {
  final repository = ref.watch(notesRepositoryProvider);
  await repository.deleteNote(tenderNumber);
  ref.invalidate(notesProvider);
});
