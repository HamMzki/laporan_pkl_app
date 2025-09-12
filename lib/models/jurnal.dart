class Jurnal {
  final int id;
  final int userId;
  final String judul;
  final String deskripsi;
  final DateTime tanggal;
  final String? foto;
  final DateTime createdAt;
  final DateTime updatedAt;

  Jurnal({
    required this.id,
    required this.userId,
    required this.judul,
    required this.deskripsi,
    required this.tanggal,
    this.foto,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Jurnal.fromJson(Map<String, dynamic> json) {
    return Jurnal(
      id: json['id'],
      userId: json['user_id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      tanggal: DateTime.parse(json['tanggal']),
      foto: json['foto_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
