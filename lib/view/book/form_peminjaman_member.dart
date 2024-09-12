import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormPeminjamanMember extends StatefulWidget {
  final String bukuId; // ID buku yang akan dipinjam
  final String namaMember; // Nama peminjam hanya untuk tampilan
  final int memberId; // ID member yang diambil dari login

  const FormPeminjamanMember({
    Key? key,
    required this.bukuId,
    required this.namaMember,
    required this.memberId,
  }) : super(key: key);

  @override
  _FormPeminjamanMemberState createState() => _FormPeminjamanMemberState();
}

class _FormPeminjamanMemberState extends State<FormPeminjamanMember> {
  final TextEditingController _tanggalPeminjamanController =
      TextEditingController();
  final TextEditingController _tanggalPengembalianController =
      TextEditingController();
  final TextEditingController _memberIdController = TextEditingController();

  DateTime? _selectedTanggalPeminjaman;
  DateTime? _selectedTanggalPengembalian;

  @override
  void initState() {
    super.initState();
    _memberIdController.text = widget.memberId.toString();
  }

  Future<void> _selectTanggalPeminjaman(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggalPeminjaman ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedTanggalPeminjaman) {
      setState(() {
        _selectedTanggalPeminjaman = picked;
        _tanggalPeminjamanController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTanggalPengembalian(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggalPengembalian ?? DateTime.now(),
      firstDate: _selectedTanggalPeminjaman ?? DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedTanggalPengembalian) {
      setState(() {
        _selectedTanggalPengembalian = picked;
        _tanggalPengembalianController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitPeminjaman() async {
    final tanggalPeminjaman = _tanggalPeminjamanController.text;
    final tanggalPengembalian = _tanggalPengembalianController.text;

    if (tanggalPeminjaman.isEmpty || tanggalPengembalian.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Harap lengkapi tanggal peminjaman dan pengembalian')),
      );
      return;
    }

    if (_selectedTanggalPengembalian != null &&
        _selectedTanggalPeminjaman != null &&
        _selectedTanggalPengembalian!.isBefore(_selectedTanggalPeminjaman!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Tanggal pengembalian tidak boleh sebelum tanggal peminjaman')),
      );
      return;
    }

    if (widget.memberId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID member tidak valid.')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null');
      }

      final url =
          'http://perpus-api.mamorasoft.com/api/peminjaman/book/${widget.bukuId}/member/${widget.memberId}';
      final response = await Dio().post(
        url,
        data: {
          'tanggal_peminjaman': tanggalPeminjaman,
          'tanggal_pengembalian': tanggalPengembalian,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 201 ||
            responseData['message'] == 'Sukses melakukan peminjaman') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Peminjaman berhasil disimpan!')),
          );
          Navigator.pushReplacementNamed(
            context,
            '/list_member_book',
            arguments: {
              'namaMember': widget.namaMember,
              'memberId': widget.memberId,
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Gagal menyimpan peminjaman. Coba lagi.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Gagal menyimpan peminjaman. Status tidak sesuai.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Member ID in build: ${widget.memberId}');

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          title: const Text('Form Peminjaman Buku'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Form Peminjaman Buku',
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Ubah warna judul menjadi hitam
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Radius untuk Card
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID Buku',
                          style:
                              Theme.of(context).textTheme.subtitle1?.copyWith(
                                    fontWeight: FontWeight
                                        .w500, // Berat font sedikit lebih ringan
                                    color: Colors.grey, // Warna teks abu-abu
                                    fontSize:
                                        14.0, // Ukuran font sedikit lebih kecil
                                  ),
                        ),
                        const SizedBox(
                            height: 8.0), // Jarak antara teks dan field form
                        TextFormField(
                          initialValue: widget.bukuId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[
                                200], // Warna latar belakang field untuk disabled
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  12.0), // Radius untuk field
                              borderSide: BorderSide.none, // Menghapus pembatas
                            ),
                            hintText: 'ID Buku',
                            hintStyle: TextStyle(
                              color: Colors.grey, // Warna placeholder abu-abu
                              fontSize:
                                  12.0, // Ukuran font placeholder lebih kecil
                            ),
                            suffixIcon: Icon(Icons.book,
                                color:
                                    Colors.grey), // Ikon buku di sebelah kanan
                          ),
                          readOnly: true,
                          style: TextStyle(
                            color: Colors.grey[
                                600], // Warna teks abu-abu untuk initialValue
                            fontWeight:
                                FontWeight.bold, // Menambahkan ketebalan font
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ID Member',
                          style:
                              Theme.of(context).textTheme.subtitle1?.copyWith(
                                    fontWeight: FontWeight
                                        .w500, // Berat font sedikit lebih ringan
                                    color: Colors.grey, // Warna teks abu-abu
                                    fontSize:
                                        14.0, // Ukuran font sedikit lebih kecil
                                  ),
                        ),
                        const SizedBox(
                            height: 8.0), // Jarak antara teks dan field form
                        TextFormField(
                          controller: _memberIdController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[
                                200], // Warna latar belakang field untuk disabled
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  12.0), // Radius untuk field
                              borderSide: BorderSide.none, // Menghapus pembatas
                            ),
                            hintText: 'ID Member',
                            hintStyle: TextStyle(
                              color: Colors.grey, // Warna placeholder abu-abu
                              fontSize:
                                  12.0, // Ukuran font placeholder lebih kecil
                            ),
                            suffixIcon: Icon(Icons.card_membership,
                                color: Colors.grey), // Ikon ID di sebelah kanan
                          ),
                          readOnly: true,
                          style: TextStyle(
                            color: Colors.grey[
                                600], // Warna teks abu-abu untuk initialValue
                            fontWeight:
                                FontWeight.bold, // Menambahkan ketebalan font
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nama Peminjam',
                          style:
                              Theme.of(context).textTheme.subtitle1?.copyWith(
                                    fontWeight: FontWeight
                                        .w500, // Berat font sedikit lebih ringan
                                    color: Colors.grey, // Warna teks abu-abu
                                    fontSize:
                                        14.0, // Ukuran font sedikit lebih kecil
                                  ),
                        ),
                        const SizedBox(
                            height: 8.0), // Jarak antara teks dan field form
                        TextFormField(
                          initialValue: widget.namaMember,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[
                                200], // Warna latar belakang field untuk disabled
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  12.0), // Radius untuk field
                              borderSide: BorderSide.none, // Menghapus pembatas
                            ),
                            hintText: 'Nama Peminjam',
                            hintStyle: TextStyle(
                              color: Colors.grey, // Warna placeholder abu-abu
                              fontSize:
                                  12.0, // Ukuran font placeholder lebih kecil
                            ),
                            suffixIcon: Icon(Icons.person,
                                color:
                                    Colors.grey), // Ikon orang di sebelah kanan
                          ),
                          readOnly: true,
                          style: TextStyle(
                            color: Colors.grey[
                                600], // Warna teks abu-abu untuk initialValue
                            fontWeight:
                                FontWeight.bold, // Menambahkan ketebalan font
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Tanggal Peminjaman',
                          style:
                              Theme.of(context).textTheme.subtitle1?.copyWith(
                                    fontWeight: FontWeight
                                        .w500, // Berat font sedikit lebih ringan
                                    color: Colors.grey, // Warna teks abu-abu
                                    fontSize:
                                        14.0, // Ukuran font sedikit lebih kecil
                                  ),
                        ),
                        const SizedBox(
                            height: 8.0), // Jarak antara teks dan field form
                        TextFormField(
                          controller: _tanggalPeminjamanController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                Colors.grey[200], // Warna latar belakang field
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  12.0), // Radius untuk field
                              borderSide: BorderSide.none, // Menghapus pembatas
                            ),
                            hintText: 'Pilih tanggal peminjaman',
                            hintStyle: TextStyle(
                              color: Colors.grey, // Warna placeholder abu-abu
                              fontSize:
                                  12.0, // Ukuran font placeholder lebih kecil
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today,
                                  color: Colors
                                      .grey), // Ikon kalender di sebelah kanan
                              onPressed: () =>
                                  _selectTanggalPeminjaman(context),
                            ),
                          ),
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tanggal Pengembalian',
                          style:
                              Theme.of(context).textTheme.subtitle1?.copyWith(
                                    fontWeight: FontWeight
                                        .w500, // Berat font sedikit lebih ringan
                                    color: Colors.grey, // Warna teks abu-abu
                                    fontSize:
                                        14.0, // Ukuran font sedikit lebih kecil
                                  ),
                        ),
                        const SizedBox(
                            height: 8.0), // Jarak antara teks dan field form
                        TextFormField(
                          controller: _tanggalPengembalianController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                Colors.grey[200], // Warna latar belakang field
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  12.0), // Radius untuk field
                              borderSide: BorderSide.none, // Menghapus pembatas
                            ),
                            hintText: 'Pilih tanggal pengembalian',
                            hintStyle: TextStyle(
                              color: Colors.grey, // Warna placeholder abu-abu
                              fontSize:
                                  12.0, // Ukuran font placeholder lebih kecil
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today,
                                  color: Colors
                                      .grey), // Ikon kalender di sebelah kanan
                              onPressed: () =>
                                  _selectTanggalPengembalian(context),
                            ),
                          ),
                          readOnly: true,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Aksi untuk tombol Cancel
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey, // Warna tombol Cancel
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12.0), // Radius tombol
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _submitPeminjaman,
                              style: ElevatedButton.styleFrom(
                                primary:
                                    Colors.orangeAccent, // Warna tombol Simpan
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12.0), // Radius tombol
                                ),
                              ),
                              child: const Text('Simpan'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
