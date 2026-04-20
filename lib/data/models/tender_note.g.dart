// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tender_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TenderNoteAdapter extends TypeAdapter<TenderNote> {
  @override
  final int typeId = 0;

  @override
  TenderNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TenderNote(
      tenderNumber: fields[0] as String,
      title: fields[1] as String,
      noteText: fields[2] as String,
      price: fields[3] as double,
      type: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TenderNote obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.tenderNumber)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.noteText)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TenderNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
