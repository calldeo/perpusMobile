import 'package:belajar_flutter_perpus/view/peminjaman/detail_peminjaman.dart';
import 'package:belajar_flutter_perpus/view/peminjaman/tambah_peminjaman.dart';
import 'package:belajar_flutter_perpus/view/persetujuan/detail_persetujuan.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PeminjamanPage extends StatefulWidget {
  @override
  _PeminjamanPageState createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  List<dynamic> peminjamanList = [];
  List<dynamic> _originalPeminjamanList = [];
  final String baseUrl = "http://perpus-api.mamorasoft.com/";
  final String endpoint = "api/peminjaman/all";
  bool _isAscending = true;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchPeminjaman);
    _loadPeminjaman();
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchPeminjaman);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPeminjaman() async {
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

      if (data is Map<String, dynamic> &&
          data.containsKey('data') &&
          data['data'] is Map<String, dynamic> &&
          data['data'].containsKey('peminjaman') &&
          data['data']['peminjaman'] is List<dynamic>) {
        final peminjamanData = data['data']['peminjaman'];
        setState(() {
          _originalPeminjamanList = peminjamanData;
          peminjamanList = peminjamanData.where((peminjaman) {
            final status = peminjaman['status'];
            return status != '2' && status != '3';
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Unexpected data format for peminjaman');
      }
    } catch (e) {
      log('Error fetching peminjaman: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPeminjaman() async {
    setState(() {
      _isLoading = true;
    });
    await fetchPeminjaman();
  }

  void _searchPeminjaman() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      peminjamanList = _originalPeminjamanList.where((peminjaman) {
        final status = peminjaman['status'];
        final bookTitle = peminjaman['book']['judul']?.toLowerCase() ?? '';
        final memberName = peminjaman['member']['name']?.toLowerCase() ?? '';
        final loanDate = peminjaman['tanggal_peminjaman']?.toLowerCase() ?? '';

        return (status != '2' && status != '3') &&
            (bookTitle.contains(query) ||
                memberName.contains(query) ||
                loanDate.contains(query));
      }).toList();
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      peminjamanList.sort((a, b) {
        final bookTitleA = a['book']['judul'] ?? '';
        final bookTitleB = b['book']['judul'] ?? '';

        return _isAscending
            ? bookTitleA.compareTo(bookTitleB)
            : bookTitleB.compareTo(bookTitleA);
      });
    });
  }

  Future<void> _refreshPeminjaman() async {
    await _loadPeminjaman();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF03346E), Color(0xFF1E5AA8)],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : RefreshIndicator(
                onRefresh: _refreshPeminjaman,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40), // Tambahkan jarak di atas
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Data Peminjaman Buku',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TambahPeminjamanPage(),
                                ),
                              );
                            },
                            icon: Icon(Icons.add, color: Color(0xFF03346E)),
                            label: Text('Tambah',
                                style: TextStyle(color: Color(0xFF03346E))),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Cari peminjaman',
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.search,
                                      color: Color(0xFF03346E)),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 14.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          IconButton(
                            icon: Icon(
                              _isAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: Colors.white,
                            ),
                            onPressed: _toggleSortOrder,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: peminjamanList.length,
                        itemBuilder: (context, index) {
                          final peminjaman = peminjamanList[index];
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Color(0xFF03346E),
                                child: Icon(Icons.book, color: Colors.white),
                              ),
                              title: Text(
                                peminjaman['book']['judul'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF03346E),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Text(
                                    'Peminjam: ${peminjaman['member']['name'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Tanggal: ${_formatDate(peminjaman['tanggal_peminjaman'])}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: Color(0xFF03346E)),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPersetujuanPage(
                                      peminjaman: peminjaman,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _refreshPeminjaman();
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
