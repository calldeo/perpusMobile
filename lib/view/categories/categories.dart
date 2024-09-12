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
  List<Map<String, String>> allCategories = []; // Store all categories
  List<Map<String, String>> displayedCategories =
      []; // Categories to display on the current page
  String sUrl = "http://perpus-api.mamorasoft.com/api/";
  bool _isAscending = true;
  bool _isLoading = true;
  int _currentPage = 1; // Current page for pagination
  int _limit = 10; // Number of items per page
  TextEditingController _searchController = TextEditingController();
  int _totalItems = 0; // Total items available

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
      _totalItems = data.length; // Update total items

      // Store all categories and set the initial displayed categories
      setState(() {
        allCategories = data
            .map((category) => {
                  'id': category['id'].toString(),
                  'name': category['nama_kategori'] as String,
                })
            .toList();
        _updateDisplayedCategories(); // Update displayed categories based on the current page
        _isLoading = false; // Selesai loading
      });
    } catch (e) {
      log('Error fetching categories: $e');
      setState(() {
        _isLoading = false; // Selesai loading dengan error
      });
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
      _updateDisplayedCategories(); // Update displayed categories after sorting
    });
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      displayedCategories = allCategories.where((category) {
        return category['name']!.toLowerCase().contains(query);
      }).toList();
      _updateDisplayedCategories(); // Update displayed categories after filtering
    });
  }

  Future<void> _refreshCategories() async {
    await fetchCategories(); // Refresh categories
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
    bool isPreviousButtonDisabled = _currentPage == 1;
    bool isNextButtonDisabled = (_currentPage * _limit) >= _totalItems;

    return Scaffold(
      body: _isLoading && allCategories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshCategories,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kategori Buku',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TambahCategoriesPage(
                                        onRefresh: _refreshCategories,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    _refreshCategories(); // Refresh after adding a new category
                                  }
                                },
                                child: Text('Tambah'),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors
                                      .orangeAccent, // Warna latar belakang tombol
                                  onPrimary: Colors.white, // Warna teks tombol
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10), // Padding tombol
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12.0), // Radius 12.0
                                  ),
                                ),
                              ),
                              // Jika ingin menambahkan spasi atau elemen lain
                              // SizedBox(width: 10),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search categories',
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search,
                                    color: Colors.orangeAccent),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10.0),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: Colors.orangeAccent,
                          ),
                          onPressed: _toggleSortOrder,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: displayedCategories.length,
                        itemBuilder: (context, index) {
                          final category = displayedCategories[index];
                          return Card(
                            elevation: 0,
                            margin: EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                                leading: Icon(
                                  Icons.category_outlined,
                                  color: Colors.orangeAccent,
                                ),
                                title: Text(
                                  category['name']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.orangeAccent,
                                ),
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
                                    _refreshCategories(); // Refresh after viewing category detail
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed:
                              isPreviousButtonDisabled ? null : _previousPage,
                          child: Text('Previous'),
                          style: ElevatedButton.styleFrom(
                            primary: isPreviousButtonDisabled
                                ? Colors.grey
                                : Colors.orangeAccent, // Background color
                            onPrimary: Colors.white, // Text color
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        Text(
                          'Page $_currentPage of ${(_totalItems / _limit).ceil()}',
                          style: TextStyle(fontSize: 16),
                        ),
                        ElevatedButton(
                          onPressed: isNextButtonDisabled ? null : _nextPage,
                          child: Text('Next'),
                          style: ElevatedButton.styleFrom(
                            primary: isNextButtonDisabled
                                ? Colors.grey
                                : Colors.orangeAccent, // Background color
                            onPrimary: Colors.white, // Text color
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
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
