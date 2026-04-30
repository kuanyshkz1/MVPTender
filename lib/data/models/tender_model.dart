import '../../domain/entities/tender.dart';

class TenderModel {
  final String number;
  final String title;
  final String customer;
  final String bin;
  final double price;
  final String type;
  final String status;
  final DateTime endDate;

  TenderModel({
    required this.number,
    required this.title,
    required this.customer,
    required this.bin,
    required this.price,
    required this.type,
    required this.status,
    required this.endDate,
  });

  // Безопасный парсинг JSON от сервера Госзакупок v3
  factory TenderModel.fromJson(Map<String, dynamic> json) {
    return TenderModel(
      number:
          json['numberAnno']?.toString() ??
          json['number_anno']?.toString() ??
          json['number']?.toString() ??
          'Без номера',
      title:
          json['nameRu']?.toString() ??
          json['name_ru']?.toString() ??
          'Без названия',
      customer:
          json['orgNameRu']?.toString() ??
          json['customerNameRu']?.toString() ??
          json['customer_name_ru']?.toString() ??
          'Неизвестный заказчик',
      bin:
          json['orgBin']?.toString() ??
          json['customerBin']?.toString() ??
          json['customer_bin']?.toString() ??
          'Нет БИН',
      price:
          double.tryParse(
            json['totalSum']?.toString() ??
                json['total_sum']?.toString() ??
                '0',
          ) ??
          0.0,
      type: 'Запрос ценовых предложений', // Пока заглушка
      status:
          (json['refBuyStatusId']?.toString() ??
                  json['ref_buy_status_id']?.toString()) ==
              '210'
          ? 'Прием заявок'
          : 'Завершено',
      endDate: (json['endDate'] ?? json['end_date']) != null
          ? DateTime.tryParse(
                  (json['endDate'] ?? json['end_date']).toString(),
                ) ??
                DateTime.now()
          : DateTime.now().add(const Duration(days: 1)),
    );
  }

  Tender toDomain() {
    return Tender(
      number: number,
      title: title,
      customer: customer,
      bin: bin,
      price: price,
      type: type,
      status: status,
      endDate: endDate,
    );
  }
}
