import 'package:belajar_flutter_perpus/view/peminjaman/detail_peminjaman.dart';
import 'package:belajar_flutter_perpus/view/persetujuan/detail_persetujuan.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class PersetujuanPage extends StatefulWidget {
  @override
  _PersetujuanPageState createState() => _PersetujuanPageState();
}

class _PersetujuanPageState extends State<PersetujuanPage> {
  List<dynamic> peminjamanList = [];
  List<dynamic> _originalPeminjamanList = []; // Menyimpan data asli
  final String baseUrl = "http://perpus-api.mamorasoft.com/";
  final String endpoint = "api/peminjaman/all";
  bool _isAscending = true;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchPersetujuan);
    _loadPersetujuan();
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchPersetujuan);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPersetujuan() async {
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
            // Menampilkan hanya persetujuan dengan status 1 dan 2
            return status != '1' && status != '3';
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Unexpected data format for persetujuan');
      }
    } catch (e) {
      log('Error fetching persetujuan: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPersetujuan() async {
    setState(() {
      _isLoading = true;
    });
    await fetchPersetujuan();
  }

  void _searchPersetujuan() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      peminjamanList = _originalPeminjamanList.where((peminjaman) {
        final status = peminjaman['status'];
        final bookTitle = peminjaman['book']['judul']?.toLowerCase() ?? '';
        final memberName = peminjaman['member']['name']?.toLowerCase() ?? '';
        final loanDate = peminjaman['tanggal_peminjaman']?.toLowerCase() ?? '';

        // Hanya menampilkan data dengan status yang valid
        return (status != '1' && status != '3') &&
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

  Future<void> _refreshPersetujuan() async {
    await _loadPersetujuan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshPersetujuan,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Data Persetujuan Buku',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
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
                                hintText: 'Search persetujuan',
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
                        itemCount: peminjamanList.length,
                        itemBuilder: (context, index) {
                          final peminjaman = peminjamanList[index];
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
                                leading: Icon(Icons.approval_outlined,
                                    size: 50, color: Colors.orangeAccent),
                                title: Text(
                                  peminjaman['book']['judul'] ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nama Member: ${peminjaman['member']['name'] ?? 'N/A'}',
                                    ),
                                    Text(
                                        'Tanggal Peminjaman: ${peminjaman['tanggal_peminjaman'] ?? 'N/A'}'),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.orangeAccent,
                                ),
                                onTap: () async {
                                  // Navigate to DetailPersetujuanPage and wait for result
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailPeminjamanPage(
                                        peminjaman: peminjaman,
                                      ),
                                    ),
                                  );

                                  // Check if the result is true (indicating a refresh is needed)
                                  if (result == true) {
                                    _refreshPersetujuan();
                                  }
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
