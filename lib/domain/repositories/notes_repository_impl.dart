import 'package:hive_flutter/hive_flutter.dart';
import '../repositories/i_notes_repository.dart';
import '../../data/models/tender_note.dart';

class NotesRepositoryImpl implements INotesRepository {
  // Подключаемся к нашей типизированной коробке
  final Box<TenderNote> _box = Hive.box<TenderNote>('notesBox');

  @override
  Future<List<TenderNote>> getAllNotes() async {
    // Просто возвращаем все значения из коробки в виде списка
    return _box.values.toList();
  }

  @override
  Future<void> saveNote(TenderNote note) async {
    // Кладём в коробку. Ключом будет номер тендера (tenderNumber).
    // Если тендер с таким номером уже есть — Hive просто обновит его (Update).
    // Если нет — создаст новый (Create).
    await _box.put(note.tenderNumber, note);
  }

  @override
  Future<void> deleteNote(String tenderNumber) async {
    // Удаляем тендер из избранного по его номеру
    await _box.delete(tenderNumber);
  }
}