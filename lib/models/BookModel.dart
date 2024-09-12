class BookModel {
  final int id;
  final String judul;
  final int categoryId;
  final String pengarang;
  final String penerbit;
  final String tahun;
  final int stok;
  final String? path; // Menyimpan path sebagai string

  BookModel({
    required this.id,
    required this.judul,
    required this.categoryId,
    required this.pengarang,
    required this.penerbit,
    required this.tahun,
    required this.stok,
    this.path, // Path opsional
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      judul: json['judul'],
      categoryId: json['category_id'],
      pengarang: json['pengarang'],
      penerbit: json['penerbit'],
      tahun: json['tahun'],
      stok: json['stok'],
      path: json['path'] as String?, // Ambil path sebagai string
    );
  }
}
