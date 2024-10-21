import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import package intl
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'package:belajar_flutter_perpus/models/BookModel.dart';
import 'package:belajar_flutter_perpus/models/CategoryModel.dart';

class AddBookPage extends StatefulWidget {
  final VoidCallback onRefresh;

  AddBookPage({required this.onRefresh});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _stockController = TextEditingController();

  DateTime? _selectedDate;
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  String apiUrl = "http://perpus-api.mamorasoft.com/api/";
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final fetchedCategories = await _fetchCategories();
      setState(() {
        _categories = fetchedCategories;
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      });
    } catch (e) {
      log('Error loading categories: $e');
    }
  }

  Future<List<CategoryModel>> _fetchCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null');
      }

      final response = await Dio().get(
        '${apiUrl}category/all/all',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log('Full Response Data: ${response.data.toString()}');

      final List<dynamic> data = response.data['data']['categories'] ?? [];
      return data.map((category) => CategoryModel.fromJson(category)).toList();
    } catch (e) {
      log('Error fetching categories: $e');
      return [];
    }
  }

  Future<void> _addBook() async {
    if (_titleController.text.isEmpty ||
        _authorController.text.isEmpty ||
        _publisherController.text.isEmpty ||
        _selectedDate == null ||
        _stockController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
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
        '${apiUrl}book/create',
        data: FormData.fromMap({
          'judul': _titleController.text,
          'category_id': _selectedCategory!.id,
          'pengarang': _authorController.text,
          'penerbit': _publisherController.text,
          'tahun': DateFormat('yyyy').format(_selectedDate!),
          'stok': int.parse(_stockController.text),
          'path': _filePath != null
              ? await MultipartFile.fromFile(_filePath!)
              : null,
        }),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      var jsonResponse = response.data;
      log(jsonResponse.toString());

      if (jsonResponse['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book added successfully')),
        );
        widget.onRefresh(); // Panggil fungsi refresh dari BookPage
        Navigator.pop(context); // Kembali ke BookPage
      } else {
        var errorMessage = 'Failed to add book';
        if (response.data is Map<String, dynamic> &&
            response.data['message'] != null) {
          errorMessage = response.data['message'].toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      log('Error adding book: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add book')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0), // Jarak antara teks dan form field
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(8.0), // Ukuran radius dikurangi
                borderSide: BorderSide.none,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0), // Jarak antara ikon dan teks
                child: Icon(icon, color: Colors.grey),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0), // Jarak antara teks dan form field
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(8.0), // Ukuran radius dikurangi
                borderSide: BorderSide.none,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0), // Jarak antara ikon dan teks
                child: Icon(icon, color: Colors.grey),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.0), // Jarak antara teks dan tombol
          InkWell(
            onTap: () {
              // Tampilkan modal dari bawah
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    height: 300, // Sesuaikan tinggi modal
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Kategori',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(category.namaKategori),
                                    trailing: Radio<CategoryModel>(
                                      value: category,
                                      groupValue: _selectedCategory,
                                      onChanged: (CategoryModel? value) {
                                        // Saat kategori dipilih, perbarui nilai dan tutup modal
                                        setState(() {
                                          _selectedCategory = value;
                                        });
                                        Navigator.pop(context);
                                      },
                                      activeColor: Colors
                                          .orange, // Warna oranye untuk radio button
                                    ),
                                    onTap: () {
                                      // Saat list tile ditekan, update kategori yang dipilih
                                      setState(() {
                                        _selectedCategory = category;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  Divider(), // Divider di bawah setiap kategori
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Ukuran radius dikurangi
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              // Tampilkan kategori terpilih atau placeholder jika belum ada yang dipilih
              child: Text(
                _selectedCategory?.namaKategori ?? 'Pilih Kategori',
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedCategory != null
                      ? Colors.black87
                      : Colors.black54, // Ubah warna jika belum dipilih
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tahun Terbit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.0), // Jarak antara teks dan date picker
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Ukuran radius dikurangi
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : DateFormat('yyyy').format(_selectedDate!),
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Book',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.orange),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Book Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(_titleController, 'Judul', Icons.title),
                    _buildDropdownField(),
                    _buildTextField(
                        _authorController, 'Pengarang', Icons.person),
                    _buildTextField(
                        _publisherController, 'Penerbit', Icons.business),
                    _buildDatePickerField(),
                    _buildNumberField(
                        _stockController, 'Stock', Icons.countertops),
                    ElevatedButton(
                      onPressed: _selectImage,
                      child: Text('Select Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        textStyle: TextStyle(
                          fontSize: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                            width:
                                16.0), // Jarak antara tombol Select Image dan tombol lainnya
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              ElevatedButton(
                                onPressed: _addBook,
                                child: Text('Simpan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrangeAccent,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
