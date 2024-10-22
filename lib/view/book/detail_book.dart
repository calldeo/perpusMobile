import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:belajar_flutter_perpus/models/CategoryModel.dart';

class DetailBookPage extends StatefulWidget {
  final int bookId;
  final VoidCallback? onRefresh;

  DetailBookPage({required this.bookId, this.onRefresh});

  @override
  _DetailBookPageState createState() => _DetailBookPageState();
}

class _DetailBookPageState extends State<DetailBookPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _pengarangController;
  late TextEditingController _penerbitController;
  late TextEditingController _tahunController;
  late TextEditingController _stokController;
  CategoryModel? _selectedCategory;
  late Future<void> _fetchDataFuture;
  DateTime? _selectedDate;

  File? _selectedImage;
  String? _imageUrl;

  static const String baseUrl = 'http://perpus-api.mamorasoft.com/api';
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchDataFuture = _fetchData();
  }

  void _initializeControllers() {
    _judulController = TextEditingController();
    _pengarangController = TextEditingController();
    _penerbitController = TextEditingController();
    _tahunController = TextEditingController();
    _stokController = TextEditingController();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _judulController.dispose();
    _pengarangController.dispose();
    _penerbitController.dispose();
    _tahunController.dispose();
    _stokController.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null');
      }

      final categoryResponse = await Dio().get(
        '$baseUrl/category/all/all',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log('Category Response Data: ${categoryResponse.data.toString()}');

      final List<dynamic> categoryData =
          categoryResponse.data['data']['categories'] ?? [];
      _categories = categoryData
          .map((category) => CategoryModel.fromJson(category))
          .toList();

      final bookResponse = await Dio().get(
        '$baseUrl/book/${widget.bookId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log('Book Response Data: ${bookResponse.data.toString()}');

      final bookData = bookResponse.data['data']['book'];

      setState(() {
        _judulController.text = bookData['judul'] ?? '';
        _pengarangController.text = bookData['pengarang'] ?? '';
        _penerbitController.text = bookData['penerbit'] ?? '';
        _selectedDate = DateTime.tryParse(bookData['tahun']) ?? DateTime.now();
        _tahunController.text = DateFormat('yyyy').format(_selectedDate!);
        _stokController.text = bookData['stok'].toString() ?? '';

        final categoryId = bookData['category_id'];
        _selectedCategory = _categories.firstWhere(
          (category) => category.id == categoryId,
          orElse: () => _categories.isNotEmpty
              ? _categories[0]
              : CategoryModel(id: -1, namaKategori: 'Default'),
        );

        _imageUrl = bookData['image_url'];
        _selectedImage = null;
      });
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  Future<void> _updateBook() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      return;
    }

    try {
      final formData = FormData.fromMap({
        'judul': _judulController.text,
        'category_id': _selectedCategory?.id,
        'pengarang': _pengarangController.text,
        'penerbit': _penerbitController.text,
        'tahun': int.tryParse(_tahunController.text),
        'stok': int.tryParse(_stokController.text),
        if (_selectedImage != null)
          'image_name': _selectedImage!.path.split('/').last,
      });

      final response = await Dio().post(
        '$baseUrl/book/${widget.bookId}/update',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        log(jsonResponse.toString());

        if (jsonResponse['status'] == 200) {
          if (widget.onRefresh != null) {
            widget.onRefresh!();
          }
          Navigator.pop(context);
        } else {
          log('Server Error: ${jsonResponse['message']}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Server error: ${jsonResponse['message']}'),
          ));
        }
      } else {
        log('Response Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${response.statusCode}'),
        ));
      }
    } catch (e) {
      log('Error updating book: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred while updating the book'),
      ));
    }
  }

  Future<void> _deleteBook() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      return;
    }

    try {
      final response = await Dio().delete(
        '$baseUrl/book/${widget.bookId}/delete',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      var jsonResponse = response.data;
      log(jsonResponse.toString());

      if (jsonResponse['status'] == 200) {
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error deleting book: $e');
    }
  }

  Future<void> _showDeleteConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to delete this book?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await _deleteBook();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
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

  Future<void> _selectImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _tahunController.text = DateFormat('yyyy').format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Buku',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Color(0xFF03346E),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            color: Colors.white,
            onPressed: _deleteBook,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF03346E), Color(0xFF1E5AA8)],
          ),
        ),
        child: FutureBuilder<void>(
          future: _fetchDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }

            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white)));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Buku',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              _buildTextField(
                                label: 'Judul',
                                controller: _judulController,
                                icon: Icons.book,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a title';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 8.0),
                              _buildDropdownField(
                                label: 'Category',
                                value: _selectedCategory,
                                items: _categories,
                                onChanged: (CategoryModel? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                },
                                icon: Icons.category,
                              ),
                              SizedBox(height: 8.0),
                              _buildTextField(
                                label: 'Pengarang',
                                controller: _pengarangController,
                                icon: Icons.person,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an author';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 8.0),
                              _buildTextField(
                                label: 'Penerbit',
                                controller: _penerbitController,
                                icon: Icons.publish,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a publisher';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 8.0),
                              _buildDateField(
                                label: 'Tahun Terbit',
                                controller: _tahunController,
                                icon: Icons.calendar_today,
                                onTap: _selectDate,
                              ),
                              SizedBox(height: 8.0),
                              _buildTextField(
                                label: 'Stok',
                                controller: _stokController,
                                icon: Icons.storage,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter stock';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16.0),
                              _buildImageSection(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: _selectImage,
                                    child: Text(
                                      'Select Image',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF1E5AA8),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  ElevatedButton(
                                    onPressed: _updateBook,
                                    child: Text('Simpan',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF03346E),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF03346E),
            ),
          ),
          SizedBox(height: 4.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                suffixIcon: Icon(icon, color: Color(0xFF1E5AA8)),
                border: InputBorder.none,
              ),
              validator: validator,
              keyboardType: keyboardType,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required CategoryModel? value,
    required List<CategoryModel> items,
    required void Function(CategoryModel?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF03346E),
            ),
          ),
          SizedBox(height: 4.0),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    height: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Kategori',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF03346E),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final category = items[index];
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(category.namaKategori),
                                    trailing: Radio<CategoryModel>(
                                      value: category,
                                      groupValue: value,
                                      onChanged: (CategoryModel? newValue) {
                                        onChanged(newValue);
                                        Navigator.pop(context);
                                      },
                                      activeColor: Color(0xFF1E5AA8),
                                    ),
                                    onTap: () {
                                      onChanged(category);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  Divider(),
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value?.namaKategori ?? 'Pilih Kategori',
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? Colors.black87 : Colors.black54,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(icon, color: Color(0xFF1E5AA8)),
                      SizedBox(width: 8.0),
                      Icon(Icons.arrow_drop_down, color: Color(0xFF1E5AA8)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Function() onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF03346E),
            ),
          ),
          SizedBox(height: 4.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: GestureDetector(
              onTap: onTap,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                    suffixIcon: Icon(icon, color: Color(0xFF1E5AA8)),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a year';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _selectedImage == null
            ? (_imageUrl != null
                ? Image.network(
                    _imageUrl!,
                    width: 100,
                    height: 100,
                  )
                : Text('No image selected',
                    style: TextStyle(color: Color(0xFF03346E))))
            : Image.file(
                _selectedImage!,
                width: 100,
                height: 100,
              ),
      ],
    );
  }
}
