import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  // Fungsi untuk mendapatkan data user dan token
  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final String? user = prefs.getString('user');
    final String? token = prefs.getString('token');

    if (user == null || token == null) {
      throw Exception('User data or token not found');
    }

    return {
      'user': user,
      'token': token,
    };
  }

  // Fungsi untuk mendapatkan kategori buku
  static Future<List<String>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();

    final String? categoriesJson = prefs.getString('categories');

    if (categoriesJson == null) {
      return [];
    }

    final List<dynamic> categoriesList = jsonDecode(categoriesJson);

    return categoriesList.cast<String>();
  }

  // Fungsi untuk menyimpan kategori buku
  static Future<void> saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();

    final String categoriesJson = jsonEncode(categories);

    await prefs.setString('categories', categoriesJson);
  }

  // Fungsi untuk menghapus kategori buku
  static Future<void> clearCategories() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('categories');
  }
}
