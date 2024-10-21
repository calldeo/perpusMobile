import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:belajar_flutter_perpus/models/BookModel.dart';
import 'package:belajar_flutter_perpus/models/UserModel.dart';

class TambahPeminjamanPage extends StatefulWidget {
  @override
  _TambahPeminjamanPageState createState() => _TambahPeminjamanPageState();
}

class _TambahPeminjamanPageState extends State<TambahPeminjamanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tanggalPeminjamanController =
      TextEditingController();
  final TextEditingController _tanggalPengembalianController =
      TextEditingController();
  final String baseUrl = "http://perpus-api.mamorasoft.com/";
  final String booksEndpoint = "api/book/all";
  final String membersEndpoint = "api/user/all";
  final String addPeminjamanEndpoint = "api/peminjaman/book";

  List<BookModel> books = [];
  List<User> members = [];
  BookModel? selectedBook;
  User? selectedMember;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadMembers();
  }

  Future<void> _loadBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await Dio().get(
        '$baseUrl$booksEndpoint',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('Books response data: ${response.data}');

      // Navigasi ke bagian yang benar dari respons API
      final booksData = response.data['data']['books']['data'];

      setState(() {
        books = (booksData as List)
            .map((book) => BookModel.fromJson(book))
            .toList();
      });
    } catch (e) {
      print('Error loading books: $e');
    }
  }

  Future<void> _loadMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await Dio().get(
        '$baseUrl$membersEndpoint',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('Members response data: ${response.data}');

      // Navigasi ke bagian yang benar dari respons API
      final membersData = response.data['data']['users']['data'];

      setState(() {
        members = (membersData as List)
            .map((member) => User.fromJson(member))
            .toList();
      });
    } catch (e) {
      print('Error loading members: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await Dio().post(
        '$baseUrl$addPeminjamanEndpoint/${selectedBook?.id}/member/${selectedMember?.id}',
        data: {
          'tanggal_peminjaman': _tanggalPeminjamanController.text,
          'tanggal_pengembalian': _tanggalPengembalianController.text.isEmpty
              ? null
              : _tanggalPengembalianController.text,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Print the response for debugging
      print('Response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        // Check if the response contains a success message
        if (response.data != null && response.data['status'] == 201) {
          // Verify if the data is correct
          var data = response.data['data'];
          print('Received data: $data');

          // Handle data if needed
          if (data != null && data['peminjaman'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Peminjaman berhasil ditambahkan!')),
            );
            Navigator.pop(context);
          } else {
            print('Data peminjaman tidak ditemukan di respons: $data');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menambahkan peminjaman')),
            );
          }
        } else {
          // Handle unexpected response data
          print('Unexpected response format: ${response.data}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan peminjaman')),
          );
        }
      } else {
        // More detailed error handling
        String message = 'Gagal menambahkan peminjaman';
        if (response.data != null && response.data is Map) {
          var errorData = response.data as Map;
          if (errorData.containsKey('message')) {
            message = errorData['message'];
          }
        }
        print(
            'Failed to add peminjaman: ${response.statusCode} - ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      print('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan peminjaman')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Peminjaman'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 8.0,
          shadowColor: Colors.black54,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label dan Dropdown untuk memilih buku
                  Text(
                    'Pilih Buku',
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<BookModel>(
                      value: selectedBook,
                      items: books.map((book) {
                        return DropdownMenuItem<BookModel>(
                          value: book,
                          child: Row(
                            children: [
                              Icon(Icons.book, size: 20), // Icon buku
                              SizedBox(width: 8),
                              Text(book.judul),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (BookModel? value) {
                        setState(() {
                          selectedBook = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Colors.grey[300], // Warna abu-abu untuk field
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(8.0), // Radius pada field
                          borderSide: BorderSide.none, // Hapus border
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0), // Padding di dalam field
                      ),
                      validator: (value) => value == null ? 'Pilih buku' : null,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Label dan Dropdown untuk memilih member
                  Text(
                    'Pilih Member',
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<User>(
                      value: selectedMember,
                      items: members.map((member) {
                        return DropdownMenuItem<User>(
                          value: member,
                          child: Row(
                            children: [
                              Icon(Icons.person, size: 20), // Icon member
                              SizedBox(width: 8),
                              Text(member.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (User? value) {
                        setState(() {
                          selectedMember = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Colors.grey[300], // Warna abu-abu untuk field
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(8.0), // Radius pada field
                          borderSide: BorderSide.none, // Hapus border
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0), // Padding di dalam field
                      ),
                      validator: (value) =>
                          value == null ? 'Pilih member' : null,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Label dan Input untuk tanggal peminjaman
                  Text(
                    'Tanggal Peminjaman',
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextFormField(
                      controller: _tanggalPeminjamanController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Colors.grey[300], // Warna abu-abu untuk field
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(8.0), // Radius pada field
                          borderSide: BorderSide.none, // Hapus border
                        ),
                        suffixIcon: Icon(Icons.calendar_today,
                            size: 20), // Icon kalender
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0), // Padding di dalam field
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _tanggalPeminjamanController.text =
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                          });
                        }
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Masukkan tanggal peminjaman'
                          : null,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Label dan Input untuk tanggal pengembalian
                  Text(
                    'Tanggal Pengembalian (Opsional)',
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextFormField(
                      controller: _tanggalPengembalianController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Colors.grey[300], // Warna abu-abu untuk field
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(8.0), // Radius pada field
                          borderSide: BorderSide.none, // Hapus border
                        ),
                        suffixIcon: Icon(Icons.calendar_today,
                            size: 20), // Icon kalender
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0), // Padding di dalam field
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _tanggalPengembalianController.text =
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  // Tombol Cancel dan Simpan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // Tombol di kanan
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                              context); // Kembali ke halaman sebelumnya
                        },
                        child: Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10.0),
                        ),
                      ),
                      SizedBox(width: 10), // Jarak antara tombol
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Simpan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
