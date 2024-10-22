import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:intl/intl.dart';

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
      case '2':
        return Colors.blue;
      case '1':
        return Colors.orange;
      case '3':
        return Colors.red;
      default:
        return Colors.grey;
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
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
              widget.peminjaman['status'] = newStatus;
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
        backgroundColor: Color(0xFF03346E),
        title: Text('Detail Persetujuan Buku'),
      ),
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
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 8,
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF03346E),
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildInfoRow('Penulis',
                              peminjaman['book']['penulis'] ?? 'N/A'),
                          _buildInfoRow('Penerbit',
                              peminjaman['book']['penerbit'] ?? 'N/A'),
                          Divider(height: 32),
                          Text(
                            'Informasi Peminjam',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF03346E),
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildInfoRow(
                              'Nama', peminjaman['member']['name'] ?? 'N/A'),
                          _buildInfoRow('Tanggal Peminjaman',
                              _formatDate(peminjaman['tanggal_peminjaman'])),
                          _buildInfoRow('Tanggal Pengembalian',
                              _formatDate(peminjaman['tanggal_pengembalian'])),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF03346E),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          if (status == '1' || status == 'pending')
                            Center(
                              child: ElevatedButton(
                                onPressed: _approvePersetujuan,
                                child: Text(
                                  'Setujui Peminjaman',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF03346E),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
