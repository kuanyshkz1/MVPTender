class SavedTender {
  final String tenderNumber;
  final String title;
  final String noteText;
  final double price;
  final String type;

  const SavedTender({
    required this.tenderNumber,
    required this.title,
    required this.noteText,
    required this.price,
    required this.type,
  });

  SavedTender copyWith({
    String? tenderNumber,
    String? title,
    String? noteText,
    double? price,
    String? type,
  }) {
    return SavedTender(
      tenderNumber: tenderNumber ?? this.tenderNumber,
      title: title ?? this.title,
      noteText: noteText ?? this.noteText,
      price: price ?? this.price,
      type: type ?? this.type,
    );
  }
}
