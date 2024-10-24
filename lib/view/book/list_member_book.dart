import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:belajar_flutter_perpus/models/BookModel.dart';
import 'detail_member_book.dart'; // Pastikan file ini benar-benar ada

class ListMemberBookPage extends StatefulWidget {
  final String namaMember;
  final int memberId;

  ListMemberBookPage({required this.namaMember, required this.memberId});

  @override
  _ListMemberBookPageState createState() => _ListMemberBookPageState();
}

class _ListMemberBookPageState extends State<ListMemberBookPage> {
  List<BookModel> books = [];
  List<BookModel> filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isAscending = true;
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterBooks);
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await Dio().get(
        'http://perpus-api.mamorasoft.com/api/book/all',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log('Full Response Data: ${response.data.toString()}');

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        final dataMap = data['data'] as Map<String, dynamic>;
        if (dataMap.containsKey('books')) {
          final booksData = dataMap['books'] as Map<String, dynamic>;
          if (booksData.containsKey('data')) {
            final List<dynamic> bookList = booksData['data'];
            setState(() {
              books = _sortBooks(
                bookList.map((json) => BookModel.fromJson(json)).toList(),
              );
              _totalPages = (books.length / _itemsPerPage).ceil();
              filteredBooks = _getBooksForPage(_currentPage);
              _isLoading = false;
            });
          } else {
            throw Exception('Key "data" not found in books');
          }
        } else {
          throw Exception('Key "books" not found in data');
        }
      } else {
        throw Exception('Unexpected data format');
      }
    } catch (e) {
      log('Error fetching books: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<BookModel> _sortBooks(List<BookModel> data) {
    data.sort((a, b) =>
        _isAscending ? a.judul.compareTo(b.judul) : b.judul.compareTo(a.judul));
    return data;
  }

  List<BookModel> _getBooksForPage(int page) {
    final startIndex = (page - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return books.sublist(
      startIndex,
      endIndex > books.length ? books.length : endIndex,
    );
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      books = _sortBooks(books);
      filteredBooks = _getBooksForPage(_currentPage);
    });
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredBooks = books.where((book) {
        return book.judul.toLowerCase().contains(query);
      }).toList();
      filteredBooks = _getBooksForPage(_currentPage);
    });
  }

  Future<void> _nextPage() async {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
        filteredBooks = _getBooksForPage(_currentPage);
      });
    }
  }

  Future<void> _previousPage() async {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        filteredBooks = _getBooksForPage(_currentPage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'List Buku',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.orange),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.orange),
            onPressed: _loadBooks,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBooks,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(width: 10),
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
                                hintText: 'Search books',
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search,
                                    color: Colors.orangeAccent),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 10.0,
                                ),
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
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
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
                              leading: Icon(Icons.book,
                                  size: 50, color: Colors.orangeAccent),
                              title: Text(
                                book.judul,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              subtitle: Text('Author: ${book.pengarang}'),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.orangeAccent,
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailMemberBookPage(
                                      bookId: book.id,
                                      namaMember: widget.namaMember,
                                      memberId: widget.memberId,
                                    ),
                                  ),
                                );
                                _loadBooks(); // Mengatur ulang buku setelah kembali dari halaman detail
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _currentPage > 1 ? _previousPage : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent, // Mengatur warna tombol
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  12.0), // Menambahkan radius
                            ),
                          ),
                          child: Text('Previous'),
                        ),
                        Text('Page $_currentPage of $_totalPages'),
                        ElevatedButton(
                          onPressed:
                              _currentPage < _totalPages ? _nextPage : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent, // Mengatur warna tombol
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  12.0), // Menambahkan radius
                            ),
                          ),
                          child: Text('Next'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
