import '../../data/models/tender_note.dart';

abstract class INotesRepository {
  // Read: Получить все сохраненные тендеры
  Future<List<TenderNote>> getAllNotes();

  // Create & Update: Сохранить или обновить тендер с заметкой
  Future<void> saveNote(TenderNote note);

  // Delete: Удалить из избранного
  Future<void> deleteNote(String tenderNumber);
}
