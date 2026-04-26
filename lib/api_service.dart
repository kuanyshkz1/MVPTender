import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Базовый URL вашего API
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // Пример GET-запроса для получения данных
  Future<List<dynamic>> fetchData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      // Если запрос успешен, парсим JSON-ответ
      return jsonDecode(response.body);
    } else {
      // В случае ошибки выбрасываем исключение
      throw Exception(
        'Ошибка при загрузке данных. Код: ${response.statusCode}',
      );
    }
  }

  // Пример POST-запроса для отправки данных
  Future<Map<String, dynamic>> postData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Успешное создание или обновление
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Ошибка при отправке данных. Код: ${response.statusCode}',
      );
    }
  }
}
