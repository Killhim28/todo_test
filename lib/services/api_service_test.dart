import 'package:dio/dio.dart';

class ApiServiceTest {
  final Dio _dio = Dio();

  Future<List<String>> fetchTestTodos() async {
    try {
      final response = await _dio.get('https://dummyjson.com/todos');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseMap = response.data;
        final List data = responseMap['todos'];
        return data
            .take(3)
            .map<String>((item) => item['todo'].toString())
            .toList();
      } else {
        // Сервер ответил, но не 200 ОК
        throw Exception('Ошибка сервера: код ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Отлавливаем конкретно ошибки сети (нет интернета, таймаут)
      throw Exception(
        'Ошибка сети: проверьте подключение. Детали: ${e.message}',
      );
    } catch (e) {
      // Отлавливаем ошибки парсинга или другие сюрпризы
      throw Exception('Что-то пошло не так: $e');
    }
  }
}
