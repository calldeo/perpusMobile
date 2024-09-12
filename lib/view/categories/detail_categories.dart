import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryDetailPage extends StatefulWidget {
  final String category;
  final String categoryId;
  final VoidCallback onRefresh;

  CategoryDetailPage({
    required this.category,
    required this.categoryId,
    required this.onRefresh,
  });

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final _categoryController = TextEditingController();
  final String sUrl = 'http://perpus-api.mamorasoft.com/api';
  List<dynamic> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _categoryController.text = widget.category;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await Dio().get('$sUrl/category');
      if (response.statusCode == 200) {
        setState(() {
          _categories = response.data['data'];
          _selectedCategoryId = _categories.firstWhere(
            (cat) => cat['id'] == widget.categoryId,
            orElse: () => _categories[0],
          )['id'];
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _updateKategori() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _token = prefs.getString('token');

    var dio = Dio();
    var formData = FormData.fromMap({
      'nama_kategori': _categoryController.text,
    });

    try {
      var response = await dio.post(
        '$sUrl/category/update/${widget.categoryId}',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $_token",
          },
        ),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Data kategori berhasil diubah"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        widget.onRefresh();
        Navigator.pop(context);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteKategori() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _token = prefs.getString('token');

    var dio = Dio();
    try {
      var response = await dio.delete(
        '$sUrl/category/${widget.categoryId}/delete',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $_token",
          },
        ),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Kategori berhasil dihapus"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        widget.onRefresh();
        Navigator.pop(context);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showDelete() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Kategori'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Apakah anda yakin ingin menghapus data ini?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hapus'),
              onPressed: () async {
                await _deleteKategori();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
          backgroundColor: Colors.orangeAccent[50],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Category',
          style: TextStyle(
            color: Colors.orange, // Warna teks menjadi oranye
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDelete();
            },
          ),
        ], // Background putih
        iconTheme: IconThemeData(color: Colors.orange), // Warna ikon oranye
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16), // Jarak antara AppBar dan Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min, // Mengatur ukuran Card mengikuti isinya
                  children: [
                    Text(
                      'Category Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black, // Ubah warna teks menjadi hitam
                      ),
                    ),
                    SizedBox(
                        height: 16), // Mengatur jarak antara teks dan TextField
                    TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        hintText: 'Enter category name',
                        hintStyle: TextStyle(color: Colors.orangeAccent[300]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              8.0), // Radius untuk TextField
                          borderSide:
                              BorderSide.none, // Menghilangkan border default
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        filled: true,
                        fillColor: Colors.grey[
                            200], // Warna abu-abu untuk background form field
                        suffixIcon: Icon(Icons.category,
                            color: Colors.grey), // Ikon di sebelah kanan
                      ),
                    ),
                    SizedBox(
                        height:
                            16), // Mengatur jarak antara TextField dan ElevatedButton
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          _updateKategori();
                        },
                        child: Text('Save'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orangeAccent,
                          onPrimary: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Radius untuk ElevatedButton
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
