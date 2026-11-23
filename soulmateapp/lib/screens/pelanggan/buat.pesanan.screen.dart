import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/paket.model.dart';
import '../../services/pesanan.service.dart';

class BuatPesananScreen extends StatefulWidget {
  final Paket paket;
  BuatPesananScreen({required this.paket});

  @override
  _BuatPesananScreenState createState() => _BuatPesananScreenState();
}

class _BuatPesananScreenState extends State<BuatPesananScreen> {
  // 1. Tambahkan Form Key untuk validasi
  final _formKey = GlobalKey<FormState>();
  
  final _noHpController = TextEditingController();
  final _catatanController = TextEditingController();
  final _pesananService = PesananService();
  final _picker = ImagePicker();

  File? _fotoSepatu;
  String _tingkatKekotoran = 'sedang'; // Default
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 2. Panggil fungsi untuk mengambil No HP dari Profil
    _loadNoHp();
  }

  Future<void> _loadNoHp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _noHpController.text = prefs.getString('no_hp') ?? '';
    });
  }

  // Fungsi untuk menampilkan pilihan (Kamera / Galeri)
  void _tampilkanPilihanFoto() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context); // Tutup bottom sheet
                  _pilihFoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context); // Tutup bottom sheet
                  _pilihFoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi untuk mengambil gambar berdasarkan sumber yang dipilih
  Future<void> _pilihFoto(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Kompresi gambar
      );
      if (pickedFile != null) {
        setState(() => _fotoSepatu = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  void _submitPesanan() async {
    // Validasi jika foto belum diunggah
    if (_fotoSepatu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap unggah foto sepatu!')),
      );
      return;
    }

    // Validasi form (No HP) di-handle oleh _formKey.currentState!.validate() di tombol

    setState(() => _isLoading = true);

    final success = await _pesananService.buatPesanan(
      paketId: widget.paket.id,
      fotoSepatu: _fotoSepatu!,
      noHpKontak: _noHpController.text,
      tingkatKekotoran: _tingkatKekotoran,
      catatan: _catatanController.text,
      totalHarga: widget.paket.harga,
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan berhasil dibuat!')),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat pesanan. Periksa koneksi Anda.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buat Pesanan')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form( // 3. Bungkus dengan widget Form
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Paket: ${widget.paket.namaPaket}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              
              // Upload Foto
              GestureDetector(
                onTap: _tampilkanPilihanFoto,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _fotoSepatu != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_fotoSepatu!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Unggah Foto Sepatu', style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 16),

              // Input No HP
              TextFormField(
                controller: _noHpController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(14),
                ],
                decoration: InputDecoration(
                  labelText: 'Nomor HP / WhatsApp',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'Contoh: 081234567890',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor HP wajib diisi!';
                  }
                  if (value.length < 10) {
                    return 'Nomor HP minimal 10 digit!';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Pilihan Tingkat Kekotoran
              Text('Tingkat Kekotoran Sepatu:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _tingkatKekotoran,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: [
                  DropdownMenuItem(value: 'ringan', child: Text('Ringan (Debu saja)')),
                  DropdownMenuItem(value: 'sedang', child: Text('Sedang (Noda biasa)')),
                  DropdownMenuItem(value: 'berat', child: Text('Berat (Noda membandel)')),
                ],
                onChanged: (val) => setState(() => _tingkatKekotoran = val!),
              ),
              SizedBox(height: 16),

              // Catatan
              TextFormField(
                controller: _catatanController,
                decoration: InputDecoration(
                  labelText: 'Catatan Tambahan (Opsional)', 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 24),

              // Tombol Submit dengan validasi Form
              ElevatedButton(
                onPressed: _isLoading ? null : () {
                  // 4. Validasi form sebelum memanggil submit
                  if (_formKey.currentState!.validate()) {
                    _submitPesanan();
                  }
                },
                child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white) 
                  : Text('Konfirmasi Pesanan', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}