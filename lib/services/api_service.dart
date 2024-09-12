import 'dart:convert';
import 'package:belajar_flutter_perpus/models/BookModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/BookModel.dart';
import '../models/CategoryModel.dart';

class ApiService {
  Future<T> fetchData<T>({
    required String url,
    required T Function(Map<String, dynamic> data) parser,
  }) async {
    final response = await Dio().get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      return parser(data);
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  }

  Future<List<BookModel>> fetchBooks(
      {required int page, required int perPage}) async {
    return fetchData<List<BookModel>>(
      url:
          'http://perpus-api.mamorasoft.com/api/book/all?page=$page&per_page=$perPage',
      parser: (data) {
        if (data['status'] == 200 &&
            data['data'] != null &&
            data['data']['books'] != null &&
            data['data']['books']['data'] != null) {
          final booksList = data['data']['books']['data'] as List;
          return booksList
              .map((bookJson) => BookModel.fromJson(bookJson))
              .toList();
        } else {
          throw Exception('Invalid response format.');
        }
      },
    );
  }

  Future<List<CategoryModel>> fetchCategories() async {
    return fetchData<List<CategoryModel>>(
      url: 'http://perpus-api.mamorasoft.com/api/category/all/all',
      parser: (data) {
        if (data['status'] == 200 && data['categories'] != null) {
          return (data['categories'] as List)
              .map((json) => CategoryModel.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid response format.');
        }
      },
    );
  }
}
