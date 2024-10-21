import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:belajar_flutter_perpus/view/categories/detail_categories.dart';
import 'package:belajar_flutter_perpus/view/categories/tambah_categories.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Map<String, String>> allCategories = [];
  List<Map<String, String>> displayedCategories = [];
  String sUrl = "http://perpus-api.mamorasoft.com/api/";
  bool _isAscending = true;
  bool _isLoading = true;
  int _currentPage = 1;
  int _limit = 10;
  TextEditingController _searchController = TextEditingController();
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _searchController.addListener(_filterCategories);
  }

  Future<void> fetchCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await Dio().get(
        '${sUrl}category/all/all',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log('Full Response Data: ${response.data.toString()}');

      final List<dynamic> data = response.data['data']['categories'] ?? [];
      _totalItems = data.length;

      setState(() {
        allCategories = data
            .map((category) => {
                  'id': category['id'].toString(),
                  'name': category['nama_kategori'] as String,
                })
            .toList();
        _updateDisplayedCategories();
        _isLoading = false;
      });
    } catch (e) {
      log('Error fetching categories: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateDisplayedCategories() {
    final startIndex = (_currentPage - 1) * _limit;
    final endIndex = startIndex + _limit;
    setState(() {
      displayedCategories = allCategories.sublist(startIndex,
          endIndex > allCategories.length ? allCategories.length : endIndex);
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      allCategories.sort((a, b) => _isAscending
          ? a['name']!.compareTo(b['name']!)
          : b['name']!.compareTo(a['name']!));
      _updateDisplayedCategories();
    });
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      displayedCategories = allCategories
          .where((category) => category['name']!.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _refreshCategories() async {
    await fetchCategories();
  }

  void _nextPage() {
    if ((_currentPage * _limit) < _totalItems) {
      setState(() {
        _currentPage++;
        _updateDisplayedCategories();
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _updateDisplayedCategories();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori Buku',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF03346E), Color(0xFF1E5AA8)],
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isAscending ? Icons.sort : Icons.sort_by_alpha,
                color: Colors.white),
            onPressed: _toggleSortOrder,
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TambahCategoriesPage(
                    onRefresh: _refreshCategories,
                  ),
                ),
              );
              if (result == true) {
                _refreshCategories();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF03346E)))
          : RefreshIndicator(
              onRefresh: _refreshCategories,
              color: Color(0xFF03346E),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF03346E), Color(0xFF1E5AA8)],
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari kategori',
                        prefixIcon:
                            Icon(Icons.search, color: Color(0xFF03346E)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: displayedCategories.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[300],
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final category = displayedCategories[index];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFF03346E),
                            child: Text(
                              category['name']![0].toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(category['name']!,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: Color(0xFF03346E)),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryDetailPage(
                                  category: category['name']!,
                                  categoryId: category['id']!,
                                  onRefresh: _refreshCategories,
                                ),
                              ),
                            );
                            if (result == true) {
                              _refreshCategories();
                            }
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _currentPage > 1 ? _previousPage : null,
                          child: Text('Sebelumnya',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF03346E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Text(
                          'Halaman $_currentPage dari ${(_totalItems / _limit).ceil()}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: (_currentPage * _limit) < _totalItems
                              ? _nextPage
                              : null,
                          child: Text('Selanjutnya',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF03346E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
