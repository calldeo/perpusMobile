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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshPeminjaman,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Data Pengembalian Buku',
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
                                hintText: 'Search Pengembalian',
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
                  SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: filteredPeminjaman.length,
                        itemBuilder: (context, index) {
                          final peminjaman = filteredPeminjaman[index];
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
                                leading: Icon(Icons.assignment_return_outlined,
                                    size: 50, color: Colors.orangeAccent),
                                title: Text(
                                  peminjaman['book']['judul'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nama Member: ${peminjaman['member']['name']}',
                                    ),
                                    Text(
                                        'Tanggal Pengembalian: ${peminjaman['tanggal_pengembalian']}'),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.orangeAccent,
                                ),
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
                                  // Handle item tap here if needed
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
