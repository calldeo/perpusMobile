import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class DetailPeminjamanPage extends StatefulWidget {
  final Map<String, dynamic> peminjaman;

  DetailPeminjamanPage({required this.peminjaman});

  @override
  _DetailPeminjamanPageState createState() => _DetailPeminjamanPageState();
}

class _DetailPeminjamanPageState extends State<DetailPeminjamanPage> {
  bool _isLoading = false;

  Future<void> _returnBook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final int peminjamanId = widget.peminjaman['id'] ??
          0; // ID peminjaman harus ada di data peminjaman

      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await Dio().post(
        'http://perpus-api.mamorasoft.com/api/peminjaman/book/$peminjamanId/return',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log('Return Book Response: ${response.data.toString()}');

      if (response.statusCode == 200) {
        // Buku berhasil dikembalikan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Buku berhasil dikembalikan!')),
        );
        Navigator.pop(context,
            true); // Kembali ke halaman sebelumnya dan beri tahu bahwa data perlu di-refresh
      } else {
        throw Exception('Failed to return book');
      }
    } catch (e) {
      log('Error returning book: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengembalikan buku')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final peminjaman = widget.peminjaman;

    // Ambil status peminjaman
    final String status = peminjaman['status'] ?? 'N/A';

    // Menentukan warna dan teks status berdasarkan nilai status
    Color statusColor;
    String statusText;

    switch (status) {
      case '1':
        statusColor = Colors.redAccent;
        statusText = 'Menunggu Persetujuan';
        break;
      case '2':
        statusColor = Colors.cyan;
        statusText = 'Dalam Peminjaman';
        break;
      default:
        statusColor = Colors.transparent;
        statusText = status;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text('Detail Peminjaman Buku'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${peminjaman['book']['judul'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Penulis: ${peminjaman['book']['penulis'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Penerbit Buku: ${peminjaman['book']['penerbit'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Member',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Nama: ${peminjaman['member']['name'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tanggal Peminjaman: ${peminjaman['tanggal_peminjaman'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tanggal Pengembalian: ${peminjaman['tanggal_pengembalian'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          // Menampilkan status dengan styling khusus
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor,
                              ),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: _returnBook,
                              child: Text('Kembalikan Buku'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.deepOrangeAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
