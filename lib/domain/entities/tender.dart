class Tender {
  final String number;
  final String title;
  final String customer;
  final String bin;
  final double price;
  final String type;
  final String status;
  final DateTime endDate;

  const Tender({
    required this.number,
    required this.title,
    required this.customer,
    required this.bin,
    required this.price,
    required this.type,
    required this.status,
    required this.endDate,
  });

  String get announcementUrl =>
      'https://www.goszakup.gov.kz/ru/announce/index/$number';
}
