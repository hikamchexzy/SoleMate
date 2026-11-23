import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/kelola.pesanan.service.dart';

class KelolaPesananScreen extends StatefulWidget {
  @override
  _KelolaPesananScreenState createState() => _KelolaPesananScreenState();
}

class _KelolaPesananScreenState extends State<KelolaPesananScreen> {
  final KelolaPesananService _service = KelolaPesananService();
  late Future<List<dynamic>> _futurePesanan;
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _futurePesanan = _service.getAllPesanan();
    });
  }

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

  void _showDetailPesanan(Map<String, dynamic> pesanan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detail Pesanan #${pesanan['id']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Divider(),
                  Text('Pelanggan: ${pesanan['nama_pelanggan']}'),
                  Text('No HP: ${pesanan['no_hp_kontak']}'),
                  Text('Paket: ${pesanan['nama_paket']}'),
                  Text('Kekotoran: ${pesanan['tingkat_kekotoran']}'),
                  Text('Total: ${currencyFormatter.format(pesanan['total_harga'])}'),
                  Text('Status: ${pesanan['status']}'),
                  SizedBox(height: 16),

                  // Tampilkan Foto Sepatu (dari pelanggan)
                  if (pesanan['foto_sepatu'] != null) ...[
                    Text('Foto Kondisi Awal:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Image.network(pesanan['foto_sepatu'], height: 150, fit: BoxFit.cover),
                  ],
                  SizedBox(height: 24),

                  // Tombol Aksi
                  Text('Ubah Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['diterima', 'dicuci', 'selesai', 'selesai_diambil'].map((status) {
                      return ActionChip(
                        label: Text(status.toUpperCase()),
                        backgroundColor: _getStatusColor(status).withOpacity(0.2),
                        onPressed: () async {
                          bool success = await _service.updateStatus(pesanan['id'], status);
                          if (success) {
                            Navigator.pop(context);
                            _refreshData();
                          }
                        },
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24),
                  Text('Upload Foto (Before/After):', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.add_a_photo),
                        label: Text('Before'),
                        onPressed: () => _pilihDanUploadFoto(pesanan['id'], 'before'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add_a_photo),
                        label: Text('After'),
                        onPressed: () => _pilihDanUploadFoto(pesanan['id'], 'after'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pilihDanUploadFoto(int pesananId, String tipe) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      bool success = await _service.uploadFoto(pesananId, tipe, File(picked.path));
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto $tipe berhasil diunggah')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelola Pesanan')),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: FutureBuilder<List<dynamic>>(
          future: _futurePesanan,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Belum ada pesanan masuk.'));
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final pesanan = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    onTap: () => _showDetailPesanan(pesanan),
                    title: Text('${pesanan['nama_paket']} - ${pesanan['nama_pelanggan']}'),
                    subtitle: Text('Total: ${currencyFormatter.format(pesanan['total_harga'])}'),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(pesanan['status']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pesanan['status'].toString().toUpperCase(),
                        style: TextStyle(color: _getStatusColor(pesanan['status']), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
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