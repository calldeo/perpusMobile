import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class DetailPeminjamanMemberPage extends StatefulWidget {
  final Map<String, dynamic> peminjaman;

  DetailPeminjamanMemberPage({required this.peminjaman});

  @override
  _DetailPeminjamanMemberPageState createState() =>
      _DetailPeminjamanMemberPageState();
}

class _DetailPeminjamanMemberPageState
    extends State<DetailPeminjamanMemberPage> {
  bool _isLoading = false;
  DateTime? _tanggalPengembalian;

  Color _getStatusColor(String status) {
    switch (status) {
      case '2': // Status code for approved (Dalam Peminjaman)
        return Colors.blue;
      case '1': // Status code for pending (Menunggu Persetujuan)
        return Colors.red;
      default:
        return Colors.grey; // Unknown status
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case '2':
        return 'Dalam Peminjaman';
      case '1':
        return 'Menunggu Persetujuan';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  Future<void> _approvePersetujuan() async {
    if (_tanggalPengembalian == null) {
      // Tanggal pengembalian belum dipilih
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Silakan pilih tanggal pengembalian terlebih dahulu.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String status = widget.peminjaman['status'] ?? '1';
      final int peminjamanId = widget.peminjaman['id'] ?? 0;

      if (token == null) {
        throw Exception('Token is null');
      }

      if (status == '2') {
        final response = await Dio().post(
          'http://perpus-api.mamorasoft.com/api/peminjaman/book/$peminjamanId/return',
          data: {
            'tanggal_pengembalian': _tanggalPengembalian!
                .toIso8601String(), // Mengirimkan tanggal pengembalian
          },
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
              SnackBar(content: Text('Buku berhasil dikembalikan!')),
            );
            setState(() {
              widget.peminjaman['status'] = newStatus; // Update status
            });
            Navigator.pop(context, true);
          } else {
            throw Exception(data['message'] ?? 'Gagal mengembalikan buku');
          }
        } else {
          throw Exception(
              'Gagal mengembalikan buku. Status code: ${response.statusCode}');
        }
      } else {
        throw Exception(
            'Status bukan "Dalam Peminjaman", tidak dapat mengembalikan.');
      }
    } catch (e) {
      log('Error returning book: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengembalikan buku: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _tanggalPengembalian) {
      setState(() {
        _tanggalPengembalian = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final peminjaman = widget.peminjaman;
    final String status = peminjaman['status'] ?? '1';

    // Filter hanya menampilkan yang memiliki status 1 (Menunggu Persetujuan) atau 2 (Dalam Peminjaman)
    if (status == '3') {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          title: Text('Detail Persetujuan Buku'),
        ),
        body: Center(
          child: Text('Status peminjaman tidak valid untuk ditampilkan.'),
        ),
      );
    }

    final Color statusColor = _getStatusColor(status);
    final String statusText = _getStatusText(status);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text('Detail Persetujuan Buku'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
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
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Penerbit Buku: ${peminjaman['book']['penerbit'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 14,
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
                            if (status == '2') ...[
                              // Form Tanggal Pengembalian jika status = 2
                              Text(
                                'Tanggal Pengembalian',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () => _selectDate(context),
                                child: Text(
                                  _tanggalPengembalian == null
                                      ? 'Pilih Tanggal'
                                      : '${_tanggalPengembalian!.toLocal()}'
                                          .split(' ')[0],
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.grey[900]), // Warna tombol abu-abu
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          12.0), // Membuat tombol rounded
                                    ),
                                  ),
                                  padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 12.0), // Padding tombol
                                  ),
                                ),
                              )
                            ],
                            SizedBox(height: 20),
                            if (status == '2') ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: _approvePersetujuan,
                                  child: Text('Kembalikan Buku'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green, // Warna tombol hijau
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: 10),
                            if (status != '2') ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Kembali'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey, // Warna tombol abu-abu
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
