import 'package:dio/dio.dart';

class ApiServiceTest {
  final Dio _dio = Dio();

  Future<List<String>> fetchTestTodos() async {
    try {
      final response = await _dio.get('https://dummyjson.com/todos');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseMap = response.data;
        final List data = responseMap['todos'];
        List<String> taskTitles = [];

        for (var item in data.take(3)) {
          taskTitles.add(item['todo']);
        }
        return taskTitles;
      }
    } catch (e) {
      print("Ошибка сети: $e");
    }
    return [];
  }
}
