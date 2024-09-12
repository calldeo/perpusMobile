import 'dart:developer';
import 'package:belajar_flutter_perpus/view/book/form_peminjaman_member.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:belajar_flutter_perpus/models/CategoryModel.dart';

class DetailMemberBookPage extends StatefulWidget {
  final int bookId;
  final int memberId;
  final String namaMember;
  final VoidCallback? onRefresh;

  DetailMemberBookPage({
    required this.bookId,
    required this.memberId,
    required this.namaMember,
    this.onRefresh,
  });

  @override
  _DetailMemberBookPageState createState() => _DetailMemberBookPageState();
}

class _DetailMemberBookPageState extends State<DetailMemberBookPage> {
  late TextEditingController _judulController;
  late TextEditingController _pengarangController;
  late TextEditingController _penerbitController;
  late TextEditingController _tahunController;
  late TextEditingController _stokController;
  CategoryModel? _selectedCategory;
  late Future<void> _fetchDataFuture;
  DateTime? _selectedDate;

  static const String baseUrl = 'http://perpus-api.mamorasoft.com/api';
  List<CategoryModel> _categories = [];

  String? _imageUrl; // Variabel untuk menyimpan URL gambar

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController();
    _pengarangController = TextEditingController();
    _penerbitController = TextEditingController();
    _tahunController = TextEditingController();
    _stokController = TextEditingController();

    _fetchDataFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null');
      }

      // Ambil data kategori
      final categoryResponse = await Dio().get(
        '$baseUrl/category/all/all',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log('Category Response Data: ${categoryResponse.data.toString()}');

      final List<dynamic> categoryData =
          categoryResponse.data['data']['categories'] ?? [];
      _categories = categoryData
          .map((category) => CategoryModel.fromJson(category))
          .toList();

      // Ambil detail buku berdasarkan bookId
      final bookResponse = await Dio().get(
        '$baseUrl/book/${widget.bookId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log('Book Response Data: ${bookResponse.data.toString()}');

      final bookData = bookResponse.data['data']['book'];

      setState(() {
        _judulController.text = bookData['judul'] ?? '';
        _pengarangController.text = bookData['pengarang'] ?? '';
        _penerbitController.text = bookData['penerbit'] ?? '';
        _selectedDate = DateTime.tryParse(bookData['tahun']) ?? DateTime.now();
        _tahunController.text = DateFormat('yyyy').format(_selectedDate!);
        _stokController.text = bookData['stok'].toString() ?? '';

        // Cari dan atur kategori yang sesuai dengan kategori buku
        final categoryId = bookData['category_id'];
        _selectedCategory = _categories.firstWhere(
          (category) => category.id == categoryId,
          orElse: () => _categories.isNotEmpty
              ? _categories[0]
              : CategoryModel(
                  id: -1,
                  namaKategori:
                      'Default'), // Kategori default jika tidak ada yang cocok
        );

        // Mengatur gambar jika ada
        _imageUrl = bookData['path']; // Sesuaikan dengan nama field yang benar
      });
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  Future<void> _borrowBook() async {
    // Implementasi peminjaman buku bisa ditambahkan di sini
    log('Buku berhasil dipinjam');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Buku berhasil dipinjam!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text('Pinjam Buku',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<void>(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    _imageUrl!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const SizedBox(height: 150),
                          const SizedBox(height: 16),
                          Text(
                            'Judul: ${_judulController.text}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Pengarang: ${_pengarangController.text}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Penerbit: ${_penerbitController.text}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tahun Terbit: ${_tahunController.text}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Kategori: ${_selectedCategory?.namaKategori ?? 'Tidak ada'}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Stok: ${_stokController.text}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormPeminjamanMember(
                                      bukuId: widget.bookId.toString(),
                                      namaMember: widget.namaMember,
                                      memberId: int.parse(widget.memberId
                                          .toString()), // Mengonversi dari String ke int
                                    ),
                                  ),
                                ).then((_) {
                                  if (widget.onRefresh != null) {
                                    widget.onRefresh!();
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: const Text('Pinjam Buku',
                                  style: TextStyle(fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
