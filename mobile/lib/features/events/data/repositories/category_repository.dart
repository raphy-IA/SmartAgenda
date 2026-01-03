import 'package:dio/dio.dart';
import '../models/category.dart';

class CategoryRepository {
  final Dio _dio;
  final String _baseUrl = 'http://127.0.0.1:8001/api/v1'; // Localhost for Chrome

  CategoryRepository() : _dio = Dio();

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('$_baseUrl/categories/');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print("Error fetching categories: $e");
      // Fallback local if server fails (pour ne pas bloquer l'UI)
      return [
        Category(id: '1', name: 'Travail', colorHex: '#2196F3'), 
        Category(id: '2', name: 'Personnel', colorHex: '#4CAF50'),
      ];
    }
  }
}
