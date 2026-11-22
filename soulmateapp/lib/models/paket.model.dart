class Paket {
  final int id;
  final String namaPaket;
  final String deskripsi;
  final int harga;
  final int estimasiHari;
  final String? gambar;

  Paket({
    required this.id,
    required this.namaPaket,
    required this.deskripsi,
    required this.harga,
    required this.estimasiHari,
    this.gambar,
  });

  factory Paket.fromJson(Map<String, dynamic> json) {
    return Paket(
      id: json['id'],
      namaPaket: json['nama_paket'],
      deskripsi: json['deskripsi'] ?? '-',
      harga: json['harga'],
      estimasiHari: json['estimasi_hari'],
      gambar: json['gambar'],
    );
  }
}  