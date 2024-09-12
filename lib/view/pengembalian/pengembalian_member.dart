import 'package:belajar_flutter_perpus/view/pengembalian/detail_pengembalian.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

class PengembalianMemberPage extends StatefulWidget {
  final String token;
  final int memberId;

  PengembalianMemberPage({required this.token, required this.memberId});

  @override
  _PengembalianMemberPageState createState() => _PengembalianMemberPageState();
}

class _PengembalianMemberPageState extends State<PengembalianMemberPage> {
  List<dynamic> peminjamanList = [];
  List<dynamic> _originalPeminjamanList = [];
  bool _isLoading = true;
  bool _isAscending = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchPeminjaman);
    _loadPeminjaman();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '1': // Menunggu persetujuan
        return Colors.red; // Merah
      case '2': // Dalam peminjaman
        return Colors.blue;
      case '3': // Dalam peminjaman
        return Colors.green; // Biru
      default:
        return Colors.grey; // Warna default
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case '1': // Menunggu persetujuan
        return 'Menunggu Persetujuan';
      case '2': // Dalam peminjaman
        return 'Dalam Peminjaman';
      case '3': // Dalam peminjaman
        return 'Telah Dikembalikan';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchPeminjaman);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPeminjaman() async {
    try {
      final response = await Dio().get(
        'http://perpus-api.mamorasoft.com/api/peminjaman/return',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${widget.token}',
          },
        ),
      );

      log('Full Response Data: ${response.data.toString()}');
      final data = response.data;

      if (data != null && data['data'] != null) {
        // Filter peminjaman berdasarkan memberId
        final filteredPeminjaman =
            data['data']['peminjaman'].where((peminjaman) {
          return peminjaman['member']['id'] == widget.memberId;
        }).toList();

        setState(() {
          _originalPeminjamanList = filteredPeminjaman;
          peminjamanList = _originalPeminjamanList;
          _isLoading = false;
        });
      } else {
        throw Exception('Unexpected data format');
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
        final bookTitle = peminjaman['book']['judul']?.toLowerCase() ?? '';
        return bookTitle.contains(query);
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

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Data Pengembalian Buku',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.orangeAccent),
                        onPressed: _loadPeminjaman, // Tombol refresh
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListView.builder(
                      itemCount: peminjamanList.length,
                      itemBuilder: (context, index) {
                        final peminjaman = peminjamanList[index];
                        final status = peminjaman['status'] ?? 'N/A';
                        final statusColor = _getStatusColor(status);
                        final statusText = _getStatusText(status);

                        return GestureDetector(
                          onTap: () async {
                            // Navigate to DetailPengembalianPage and wait for result
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPengembalianPage(
                                  peminjaman: peminjaman,
                                ),
                              ),
                            );

                            // Check if the result is true (indicating a refresh is needed)
                            if (result == true) {
                              _loadPeminjaman();
                            }
                          },
                          child: Card(
                            elevation: 4, // Tingkat elevasi untuk efek bayangan
                            margin: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal:
                                    10), // Margin untuk memperbesar Card
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(
                                  16.0), // Padding di dalam Card untuk memperbesar
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius:
                                        2, // Spread radius untuk efek bayangan lebih besar
                                    blurRadius:
                                        6, // Blur radius untuk efek bayangan lebih besar
                                    offset: Offset(0,
                                        4), // Offset untuk bayangan lebih besar
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${peminjaman['tanggal_peminjaman'] ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize:
                                              14, // Ukuran font untuk tanggal
                                          fontWeight: FontWeight
                                              .w600, // Berat font untuk tanggal
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(
                                              0.1), // Background color for status label
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Container(
                                    height: 3, // Tinggi garis header
                                    color: Colors
                                        .orangeAccent, // Warna garis header
                                    margin: EdgeInsets.only(
                                        bottom: 8), // Jarak bawah garis
                                  ),
                                  Text(
                                    peminjaman['book']['judul'] ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 18, // Ukuran font diperbesar
                                      fontWeight: FontWeight
                                          .bold, // Berat font lebih tebal
                                    ),
                                  ),
                                  Text(
                                    '${peminjaman['book']['pengarang'] ?? 'N/A'} / ${peminjaman['book']['penerbit'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 12, // Ukuran font disesuaikan
                                      fontWeight: FontWeight
                                          .w400, // Berat font untuk teks
                                    ),
                                  ),
                                  Text(
                                    peminjaman['book']['tahun'] ?? 'N/A',
                                    style: TextStyle(
                                      fontSize:
                                          12, // Ukuran font untuk subtitle
                                      fontWeight: FontWeight
                                          .w400, // Berat font untuk subtitle
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.orangeAccent,
                                      size: 20, // Ukuran ikon
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
