import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/kelola.paket.service.dart';

class KelolaPaketScreen extends StatefulWidget {
  @override
  _KelolaPaketScreenState createState() => _KelolaPaketScreenState();
}

class _KelolaPaketScreenState extends State<KelolaPaketScreen> {
  final KelolaPaketService _service = KelolaPaketService();
  late Future<List<dynamic>> _futurePaket;
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _futurePaket = _service.getAllPaket();
    });
  }

  // Fungsi untuk menampilkan form Tambah / Edit
  void _showFormDialog({Map<String, dynamic>? paket}) {
    final isEdit = paket != null;
    final namaController = TextEditingController(
      text: isEdit ? paket['nama_paket'] : '',
    );
    final deskripsiController = TextEditingController(
      text: isEdit ? paket['deskripsi'] : '',
    );
    final hargaController = TextEditingController(
      text: isEdit ? paket['harga'].toString() : '',
    );
    final estimasiController = TextEditingController(
      text: isEdit ? paket['estimasi_hari'].toString() : '',
    );
    File? fotoBaru;
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEdit ? 'Edit Paket' : 'Tambah Paket Baru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null)
                          setStateModal(() => fotoBaru = File(picked.path));
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: fotoBaru != null
                            ? Image.file(fotoBaru!, fit: BoxFit.cover)
                            : (isEdit && paket['gambar'] != null
                                  ? Image.network(
                                      paket['gambar'],
                                      fit: BoxFit.cover,
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image),
                                        Text('Pilih Gambar'),
                                      ],
                                    )),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Paket',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: deskripsiController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: hargaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Harga (Rp)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: estimasiController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Estimasi (Hari)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool success;
                          if (isEdit) {
                            success = await _service.editPaket(
                              id: paket['id'],
                              nama: namaController.text,
                              deskripsi: deskripsiController.text,
                              harga: int.parse(hargaController.text),
                              estimasiHari: int.parse(estimasiController.text),
                              gambar: fotoBaru,
                            );
                          } else {
                            success = await _service.tambahPaket(
                              nama: namaController.text,
                              deskripsi: deskripsiController.text,
                              harga: int.parse(hargaController.text),
                              estimasiHari: int.parse(estimasiController.text),
                              gambar: fotoBaru,
                            );
                          }

                          if (success && context.mounted) {
                            Navigator.pop(context);
                            _refreshData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Berhasil disimpan!')),
                            );
                          }
                        },
                        child: Text('Simpan'),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelola Paket Layanan')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showFormDialog(),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: FutureBuilder<List<dynamic>>(
          future: _futurePaket,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Belum ada paket layanan.'));
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final paket = snapshot.data![index];
                return Card(
                  child: ListTile(
                    leading: paket['gambar'] != null
                        ? Image.network(
                            paket['gambar'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.image, size: 50),
                    title: Text(
                      paket['nama_paket'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(currencyFormatter.format(paket['harga'])),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.black),
                          onPressed: () => _showFormDialog(paket: paket),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool success = await _service.hapusPaket(
                              paket['id'],
                            );
                            if (success) _refreshData();
                          },
                        ),
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
