import 'package:dio/dio.dart';
import '../../domain/entities/tender.dart';
import '../../domain/repositories/tender_repository.dart';
import '../models/tender_model.dart';

class TenderRepositoryImpl implements TenderRepository {
  final Dio _dio;

  TenderRepositoryImpl(this._dio);

  @override
  Future<List<Tender>> fetchTenders({String searchQuery = ''}) async {
    const token = 'b938eae8eea4060e2d19e483bec28a30';

    String filterString = '';
    if (searchQuery.isNotEmpty) {
      filterString = ', filter: { nameRu: "*$searchQuery*" }';
    }

    final query = {
      "query":
          "query { TrdBuy(limit: 25$filterString) { id nameRu numberAnno totalSum orgNameRu orgBin refBuyStatusId endDate } }",
    };

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://ows.goszakup.gov.kz/v3/graphql',
        data: query,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Server Error: ${response.statusCode}');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('Empty response from API');
      }

      if (data.containsKey('errors')) {
        throw Exception('GraphQL Error: ${data['errors']}');
      }

      if (data['data'] == null || data['data']['TrdBuy'] == null) {
        throw Exception('Empty response from API');
      }

      final lotsJson = data['data']['TrdBuy'] as List<dynamic>;
      return lotsJson
          .map((json) => TenderModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toDomain())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tenders: $e');
    }
  }
}
