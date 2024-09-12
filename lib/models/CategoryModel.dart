class CategoryModel {
  final int id;
  final String namaKategori;

  CategoryModel({required this.id, required this.namaKategori});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      namaKategori: json['nama_kategori'] as String,
    );
  }
}
