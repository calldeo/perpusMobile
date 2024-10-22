import 'package:belajar_flutter_perpus/view/pengembalian/detail_pengembalian.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class PengembalianPage extends StatefulWidget {
  @override
  _PengembalianPageState createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  List<dynamic> peminjamanList = [];
  List<dynamic> filteredPeminjaman = [];
  final String baseUrl = "http://perpus-api.mamorasoft.com/";
  final String endpoint = "api/peminjaman/return";
  bool _isAscending = true;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
    _searchController.addListener(_filterPeminjaman);
  }

  Future<List<dynamic>> fetchPeminjaman() async {
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
          data['data'].containsKey('peminjaman')) {
        return data['data']['peminjaman'];
      } else {
        throw Exception('Unexpected data format');
      }
    } catch (e) {
      log('Error fetching peminjaman: $e');
      return [];
    }
  }

  Future<void> _loadPeminjaman() async {
    setState(() {
      _isLoading = true;
    });

    final fetchedPeminjaman = await fetchPeminjaman();
    setState(() {
      peminjamanList = _sortPeminjaman(fetchedPeminjaman);
      filteredPeminjaman = peminjamanList;
      _isLoading = false;
    });
  }

  List<dynamic> _sortPeminjaman(List<dynamic> data) {
    data.sort((a, b) => _isAscending
        ? a['book']['judul'].compareTo(b['book']['judul'])
        : b['book']['judul'].compareTo(a['book']['judul']));
    return data;
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      peminjamanList = _sortPeminjaman(peminjamanList);
      _filterPeminjaman();
    });
  }

  void _filterPeminjaman() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPeminjaman = peminjamanList.where((peminjaman) {
        return peminjaman['book']['judul'].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _refreshPeminjaman() async {
    await _loadPeminjaman();
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Data Pengembalian Buku',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Cari Pengembalian',
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
                          SizedBox(width: 16),
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
                        padding: EdgeInsets.all(16.0),
                        itemCount: filteredPeminjaman.length,
                        itemBuilder: (context, index) {
                          final peminjaman = filteredPeminjaman[index];
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              leading: Icon(Icons.book,
                                  size: 40, color: Color(0xFF03346E)),
                              title: Text(
                                peminjaman['book']['judul'],
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
                                    'Peminjam: ${peminjaman['member']['name']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Tanggal Kembali: ${peminjaman['tanggal_pengembalian']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: Color(0xFF03346E)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPengembalianPage(
                                      peminjaman: peminjaman,
                                    ),
                                  ),
                                );
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
