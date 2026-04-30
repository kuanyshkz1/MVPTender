import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/saved_tender.dart';
import '../../domain/repositories/notes_repository.dart';
import '../models/tender_note.dart';

class NotesRepositoryImpl implements NotesRepository {
  final Box<TenderNote> _box = Hive.box<TenderNote>('notesBox');

  @override
  Future<List<SavedTender>> getAllNotes() async {
    return _box.values.map((note) => note.toDomain()).toList();
  }

  @override
  Future<void> saveNote(SavedTender note) async {
    await _box.put(note.tenderNumber, TenderNote.fromDomain(note));
  }

  @override
  Future<void> deleteNote(String tenderNumber) async {
    await _box.delete(tenderNumber);
  }
}
