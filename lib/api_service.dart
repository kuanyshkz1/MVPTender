import 'package:dio/dio.dart';

class ApiService {
  // Базовый URL вашего API
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  final Dio _dio = Dio();

  // Пример GET-запроса для получения данных
  Future<List<dynamic>> fetchData(String endpoint) async {
    final response = await _dio.get<List<dynamic>>('$baseUrl/$endpoint');

    if (response.statusCode == 200) {
      return response.data ?? [];
    }

    throw Exception('Ошибка при загрузке данных. Код: ${response.statusCode}');
  }

  // Пример POST-запроса для отправки данных
  Future<Map<String, dynamic>> postData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$baseUrl/$endpoint',
      data: data,
      options: Options(
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data ?? {};
    }

    throw Exception('Ошибка при отправке данных. Код: ${response.statusCode}');
  }
}
