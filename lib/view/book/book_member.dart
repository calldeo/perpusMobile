import 'package:belajar_flutter_perpus/view/book/detail_member_book.dart';
import 'package:belajar_flutter_perpus/view/book/list_book.dart';
import 'package:belajar_flutter_perpus/view/book/list_member_book.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:belajar_flutter_perpus/models/BookModel.dart';

class BookMemberPage extends StatefulWidget {
  final String namaMember;
  final int memberId;

  BookMemberPage({required this.namaMember, required this.memberId});

  @override
  _BookMemberPageState createState() => _BookMemberPageState();
}

class _BookMemberPageState extends State<BookMemberPage> {
  List<BookModel> books = [];
  List<BookModel> filteredBooks = [];
  final String baseUrl = "http://perpus-api.mamorasoft.com/";
  final String endpoint = "api/book/all?page=1&per_page=10";
  bool _isAscending = true;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(_filterBooks);
  }

  Future<List<BookModel>> fetchBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await Dio().get(
        '$baseUrl$endpoint',
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
            return bookList.map((json) => BookModel.fromJson(json)).toList();
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
      // Consider displaying an error message to the user
      return [];
    }
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    final fetchedBooks = await fetchBooks();
    setState(() {
      books = _sortBooks(fetchedBooks);
      filteredBooks = books;
      _isLoading = false;
    });
  }

  List<BookModel> _sortBooks(List<BookModel> data) {
    data.sort((a, b) =>
        _isAscending ? a.judul.compareTo(b.judul) : b.judul.compareTo(a.judul));
    return data;
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      books = _sortBooks(books);
      _filterBooks();
    });
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredBooks = books.where((book) {
        return book.judul.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _refreshBooks() async {
    await _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshBooks,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Daftar Buku',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                                leading: Icon(Icons.book_outlined,
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
                                      builder: (context) =>
                                          DetailMemberBookPage(
                                        namaMember: widget.namaMember,
                                        bookId: book.id,
                                        onRefresh: _loadBooks,
                                        memberId: int.parse(
                                            widget.memberId.toString()),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListMemberBookPage(
                                  namaMember: widget.namaMember,
                                   memberId: int.parse(
                                            widget.memberId.toString()),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'More',
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrangeAccent[200],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0,
                            ),
                            minimumSize: Size(20, 16),
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
