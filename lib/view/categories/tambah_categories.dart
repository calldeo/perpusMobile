import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class TambahCategoriesPage extends StatefulWidget {
  final VoidCallback onRefresh;

  TambahCategoriesPage({required this.onRefresh});

  @override
  _TambahCategoriesPageState createState() => _TambahCategoriesPageState();
}

class _TambahCategoriesPageState extends State<TambahCategoriesPage> {
  final _categoryController = TextEditingController();

  Future<void> _addCategory() async {
    if (_categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category name cannot be empty')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await Dio().post(
        'http://perpus-api.mamorasoft.com/api/category/create',
        data: {
          'nama_kategori': _categoryController.text,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category added successfully')),
        );
        widget.onRefresh();
        Navigator.pop(context);
      } else {
        var errorMessage = 'Failed to add category';
        if (response.data is Map<String, dynamic> &&
            response.data['message'] != null) {
          errorMessage = response.data['message'].toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      log('Error adding category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add category')),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Category',
          style: TextStyle(
            color: Colors.orange, // Warna teks menjadi oranye
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Colors.white, // Background putih
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
                              12.0), // Radius untuk TextField
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
                            color:
                                Colors.orangeAccent), // Ikon di sebelah kanan
                      ),
                    ),
                    SizedBox(
                        height:
                            16), // Mengatur jarak antara TextField dan ElevatedButton
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: _addCategory,
                        child: Text('Simpan'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.deepOrangeAccent,
                          onPrimary: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12.0), // Radius untuk ElevatedButton
                          ),
                          textStyle: TextStyle(
                            fontSize: 16,
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
