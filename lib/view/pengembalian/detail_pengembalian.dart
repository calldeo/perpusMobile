import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPengembalianPage extends StatelessWidget {
  final Map<String, dynamic> peminjaman;

  DetailPengembalianPage({required this.peminjaman});

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
    final String status = peminjaman['status'] ?? 'N/A';
    final Color statusColor = status == '3' ? Colors.green : Colors.orange;
    final String statusText =
        status == '3' ? 'Telah Dikembalikan' : 'Belum Dikembalikan';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03346E),
        title: Text('Detail Pengembalian Buku'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF03346E), Color(0xFF1E5AA8)],
          ),
        ),
        child: SingleChildScrollView(
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
                    _buildInfoRow(
                        'Penulis', peminjaman['book']['penulis'] ?? 'N/A'),
                    _buildInfoRow(
                        'Penerbit', peminjaman['book']['penerbit'] ?? 'N/A'),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
