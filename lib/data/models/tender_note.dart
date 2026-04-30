import 'package:hive/hive.dart';
import '../../domain/entities/saved_tender.dart';

// Указываем файл, который сгенерирует Flutter
part 'tender_note.g.dart';

@HiveType(typeId: 0) // typeId должен быть уникальным для каждой таблицы
class TenderNote extends HiveObject {
  @HiveField(0)
  final String tenderNumber; // Номер тендера будет нашим ID

  @HiveField(1)
  final String title; // Название тендера

  @HiveField(2)
  String noteText; // Текст заметки (это поле мы будем обновлять - Update)

  @HiveField(3)
  final double price; // Сумма (сохраняем, чтобы потом строить графики!)

  @HiveField(4)
  final String type; // Тип закупки (тоже для аналитики)

  TenderNote({
    required this.tenderNumber,
    required this.title,
    required this.noteText,
    required this.price,
    required this.type,
  });

  factory TenderNote.fromDomain(SavedTender note) {
    return TenderNote(
      tenderNumber: note.tenderNumber,
      title: note.title,
      noteText: note.noteText,
      price: note.price,
      type: note.type,
    );
  }

  SavedTender toDomain() {
    return SavedTender(
      tenderNumber: tenderNumber,
      title: title,
      noteText: noteText,
      price: price,
      type: type,
    );
  }
}
