import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class DetailPersetujuanPage extends StatefulWidget {
  final Map<String, dynamic> peminjaman;

  DetailPersetujuanPage({required this.peminjaman});

  @override
  _DetailPersetujuanPageState createState() => _DetailPersetujuanPageState();
}

class _DetailPersetujuanPageState extends State<DetailPersetujuanPage> {
  bool _isLoading = false;

  Color _getStatusColor(String status) {
    switch (status) {
      case '2': // Assuming '2' is the status code for approved
        return Colors.blue;
      case '1': // Assuming '1' is the status code for pending
        return Colors.red;
      case '3': // Assuming '3' is the status code for rejected
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case '2':
        return 'Disetujui';
      case '1':
        return 'Menunggu Persetujuan';
      case '3':
        return 'Ditolak';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  Future<void> _approvePersetujuan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String status = widget.peminjaman['status'] ?? 'pending';
      final int peminjamanId = widget.peminjaman['id'] ?? 0;

      if (token == null) {
        throw Exception('Token is null');
      }

      // Check if the status is 'pending' or '1'
      if (status == 'pending' || status == '1') {
        final response = await Dio().get(
          'http://perpus-api.mamorasoft.com/api/peminjaman/book/$peminjamanId/accept',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );

        log('Approve Persetujuan Response: ${response.data.toString()}');

        if (response.statusCode == 200) {
          final data = response.data;

          if (data['status'] == 200 && data['data'] != null) {
            final peminjaman = data['data']['peminjaman'];
            final newStatus = peminjaman['status'].toString();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Permintaan berhasil disetujui!')),
            );
            setState(() {
              widget.peminjaman['status'] = newStatus; // Update status
            });
            Navigator.pop(context, true);
          } else {
            throw Exception(data['message'] ?? 'Gagal menyetujui permintaan');
          }
        } else {
          throw Exception(
              'Gagal menyetujui persetujuan. Status code: ${response.statusCode}');
        }
      } else {
        throw Exception(
            'Status bukan "menunggu" atau "1", tidak dapat menyetujui.');
      }
    } catch (e) {
      log('Error approving persetujuan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyetujui permintaan: ${e.toString()}')),
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
    final String status = peminjaman['status'] ?? 'pending';
    final Color statusColor = _getStatusColor(status);
    final String statusText = _getStatusText(status);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text('Detail Persetujuan Buku'),
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
                              onPressed: _approvePersetujuan,
                              child: Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrangeAccent,
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
