import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/pesanan.service.dart';

class RiwayatPesananScreen extends StatefulWidget {
  @override
  _RiwayatPesananScreenState createState() => _RiwayatPesananScreenState();
}

class _RiwayatPesananScreenState extends State<RiwayatPesananScreen> {
  final PesananService _pesananService = PesananService();
  late Future<List<dynamic>> _futurePesanan;
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _futurePesanan = _pesananService.getRiwayatPesanan();
  }

  // Fungsi untuk mewarnai status agar mudah dibaca
  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu_konfirmasi': return Colors.orange;
      case 'diterima': return Colors.blue;
      case 'dicuci': return Colors.purple;
      case 'selesai': return Colors.green;
      case 'selesai_diambil': return Colors.teal;
      default: return Colors.grey;
    }
  }

  // Fungsi untuk merapikan teks status (mengganti _ dengan spasi)
  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Pesanan')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _futurePesanan = _pesananService.getRiwayatPesanan();
          });
        },
        child: FutureBuilder<List<dynamic>>(
          future: _futurePesanan,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Belum ada riwayat pesanan.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final pesanan = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris 1: Nama Paket & Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pesanan['nama_paket'],
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(pesanan['status']).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatStatus(pesanan['status']),
                                style: TextStyle(
                                  color: _getStatusColor(pesanan['status']),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        
                        // Baris 2: Info Detail
                        Text('Total: ${currencyFormatter.format(pesanan['total_harga'])}', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Kekotoran: ${pesanan['tingkat_kekotoran'].toString().toUpperCase()}'),
                        SizedBox(height: 4),
                        Text('Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(pesanan['tanggal_pesan']))}'),
                        
                        // Opsional: Tampilkan Foto Sepatu Awal (jika ada)
                        if (pesanan['foto_sepatu'] != null) ...[
                          SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              pesanan['foto_sepatu'],
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}