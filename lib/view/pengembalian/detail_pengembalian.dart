import 'package:flutter/material.dart';

class DetailPengembalianPage extends StatelessWidget {
  final Map<String, dynamic> peminjaman;

  DetailPengembalianPage({required this.peminjaman});

  @override
  Widget build(BuildContext context) {
    // Ambil status pengembalian
    final String status = peminjaman['status'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text('Detail Pengembalian Buku'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 400,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: status == '3'
                            ? Colors.greenAccent[400]
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              status == '3' ? Colors.greenAccent : Colors.grey,
                        ),
                      ),
                      child: Text(
                        status == '3' ? 'Telah Dikembalikan' : status,
                        style: TextStyle(
                          color: status == '3' ? Colors.white : Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
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
