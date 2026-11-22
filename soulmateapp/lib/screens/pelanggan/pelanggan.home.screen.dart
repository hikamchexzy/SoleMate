import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/paket.service.dart';
import '../../models/paket.model.dart';
import '../login.screen.dart'; // Untuk tombol logout

class PelangganHomeScreen extends StatefulWidget {
  @override
  _PelangganHomeScreenState createState() => _PelangganHomeScreenState();
}

class _PelangganHomeScreenState extends State<PelangganHomeScreen> {
  final PaketService _paketService = PaketService();
  late Future<List<Paket>> _futurePaket;
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _futurePaket = _paketService.getPaket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SoleMate - Layanan'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Logout sederhana (kembali ke login)
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          )
        ],
      ),
      body: FutureBuilder<List<Paket>>(
        future: _futurePaket,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Belum ada paket layanan.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final paket = snapshot.data![index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Menampilkan Gambar dari Cloudinary
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      child: paket.gambar != null 
                        ? Image.network(
                            paket.gambar!, 
                            height: 150, 
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 150, color: Colors.grey[300], child: Icon(Icons.broken_image, size: 50),
                            ),
                          )
                        : Container(
                            height: 150, color: Colors.grey[300], child: Icon(Icons.image, size: 50),
                          ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(paket.namaPaket, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(paket.deskripsi, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600])),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(currencyFormatter.format(paket.harga), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                              Text('± ${paket.estimasiHari} Hari', style: TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Nanti kita arahkan ke halaman form pesanan
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Fitur pesan segera hadir!')),
                                );
                              },
                              child: Text('Pesan Sekarang'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}