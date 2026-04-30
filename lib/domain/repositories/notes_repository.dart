import '../entities/saved_tender.dart';

abstract class NotesRepository {
  Future<List<SavedTender>> getAllNotes();
  Future<void> saveNote(SavedTender note);
  Future<void> deleteNote(String tenderNumber);
}
