import 'package:belajar_flutter_perpus/view/book/list_book.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:belajar_flutter_perpus/models/BookModel.dart';
import 'detail_book.dart';
import 'tambah_book.dart';

class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
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

  Future<void> _exportBooks() async {
    try {
      final permissionStatus = await _requestPermission();
      bool isPermissionGranted = permissionStatus.isGranted;

      if (!isPermissionGranted) {
        log('Permission to access storage not granted.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission to access storage is required.')),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        log('Token not found.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token not found. Please log in again.')),
        );
        return;
      }

      final response = await Dio().get(
        'http://perpus-api.mamorasoft.com/api/book/export/excel',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        log('Data successfully downloaded from API.');
        log('Response data size: ${response.data.length} bytes');

        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          log('Failed to get external storage directory.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to access external storage.')),
          );
          return;
        }

        final path = '${directory.path}/buku_export.xlsx';
        final file = File(path);
        await file.writeAsBytes(response.data);

        if (await file.exists()) {
          log('File saved at: $path');
          log('File exists and ready to be opened.');
          OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Books exported successfully!')),
          );
        } else {
          log('File not found after saving.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File not found after saving.')),
          );
        }
      } else {
        log('Failed to download file. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to export books. Status code: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      log('Error exporting books: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting books: $e')),
      );
    }
  }

  Future<PermissionStatus> _requestPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;

      if (status.isDenied) {
        final result = await Permission.storage.request();
        if (result.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Permission to access storage is required.')),
          );
        }
        return result;
      } else if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Permission to access storage is permanently denied. Please enable it in app settings.'),
          ),
        );
        await openAppSettings();
      }
      return status;
    }
    return PermissionStatus.granted;
  }

  Future<void> _exportPDF() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await Dio().get(
        'http://perpus-api.mamorasoft.com/api/book/export/pdf',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          responseType: ResponseType.bytes,
        ),
      );

      log('Response status: ${response.statusCode}');
      log('Response data length: ${response.data.length} bytes');

      if (response.statusCode == 200) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          log('Failed to get external storage directory.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to access external storage.')),
          );
          return;
        }

        final filePath = '${directory.path}/buku_export.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.data);

        if (await file.exists()) {
          log('File saved at: $filePath');
          OpenFile.open(filePath);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Books PDF exported successfully!')),
          );
        } else {
          log('File not found after saving.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File not found after saving.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to export PDF, status code: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      log('Error exporting PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting PDF: $e')),
      );
    }
  }

  Future<void> _importBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null');
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path),
        });

        final response = await Dio().post(
          'http://perpus-api.mamorasoft.com/api/book/import/excel',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
            validateStatus: (status) {
              return status! < 500;
            },
          ),
        );

        if (response.statusCode == 200) {
          log('Books imported successfully: ${response.data}');

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Books imported successfully!')));

          final importedBooks = response.data;
          log('Imported Books: $importedBooks');

          _refreshBooks();
        } else {
          log('Failed to import books. Status code: ${response.statusCode}');

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Failed to import books. Status: ${response.statusCode}')));
        }
      } else {
        log('No file selected.');

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No file selected.')));
      }
    } catch (e) {
      log('Error importing books: $e');

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error importing books: $e')));
    }
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
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: _exportBooks,
                          child: Text('Export Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _exportPDF,
                          child: Text('Export PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _importBooks,
                          child: Text('Import Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
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
                                      builder: (context) => DetailBookPage(
                                        bookId: book.id,
                                        onRefresh: _loadBooks,
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
                                builder: (context) => ListBookPage(),
                              ),
                            );
                          },
                          child: Text(
                            'More',
                            style: TextStyle(fontSize: 14.0),
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
