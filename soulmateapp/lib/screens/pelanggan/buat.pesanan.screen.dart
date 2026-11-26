import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/paket.model.dart';
import '../../services/auth.service.dart';
import '../../services/pesanan.service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BuatPesananScreen extends StatefulWidget {
  final Paket paket;
  BuatPesananScreen({required this.paket});

  @override
  _BuatPesananScreenState createState() => _BuatPesananScreenState();
}

class _BuatPesananScreenState extends State<BuatPesananScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noHpController = TextEditingController();
  final _catatanController = TextEditingController();
  final _pesananService = PesananService();
  final _authService = AuthService();
  final _picker = ImagePicker();

  File? _fotoSepatu;
  String _tingkatKekotoran = 'sedang'; // Default
  bool _isLoading = false;
  bool _isDataLoaded = false; // Untuk memastikan data No HP sudah dimuat

  @override
  void initState() {
    super.initState();
    _loadNoHp();
  }

  Future<void> _loadNoHp() async {
    await _authService.getProfil();
    if (!mounted)
      return; // Pastikan widget masih ada di tree sebelum memanggil setState
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _noHpController.text = prefs.getString('no_hp') ?? '';
      _isDataLoaded = true; // Data sudah dimuat
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
                leading: Icon(Icons.camera_alt, color: Colors.black),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
    }
  }

  void _submitPesanan() async {
    // Validasi jika foto belum diunggah
    if (_fotoSepatu == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Harap unggah foto sepatu!')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Pesanan berhasil dibuat!')));
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
        padding: EdgeInsets.all(24), // Padding diperlebar
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Paket (Desain Card)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.paket.namaPaket,
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(widget.paket.harga),
                      style: GoogleFonts.urbanist(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Upload Foto (Kotak Putih Bergaris Putus-putus)
              GestureDetector(
                onTap: _tampilkanPilihanFoto,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black26, width: 2),
                  ),
                  child: _fotoSepatu != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.file(
                            _fotoSepatu!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Ketuk untuk unggah foto sepatu',
                              style: GoogleFonts.urbanist(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 24),

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
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: 'Contoh: 081234567890',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Nomor HP wajib diisi!';
                  if (value.length < 10) return 'Nomor HP minimal 10 digit!';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Pilihan Tingkat Kekotoran
              DropdownButtonFormField<String>(
                value: _tingkatKekotoran,
                decoration: InputDecoration(
                  labelText: 'Tingkat Kekotoran',
                  prefixIcon: Icon(Icons.wash_outlined),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'ringan',
                    child: Text('Ringan (Debu saja)'),
                  ),
                  DropdownMenuItem(
                    value: 'sedang',
                    child: Text('Sedang (Noda biasa)'),
                  ),
                  DropdownMenuItem(
                    value: 'berat',
                    child: Text('Berat (Noda membandel)'),
                  ),
                ],
                onChanged: (val) => setState(() => _tingkatKekotoran = val!),
              ),
              SizedBox(height: 16),

              // Catatan
              TextFormField(
                controller: _catatanController,
                decoration: InputDecoration(
                  labelText: 'Catatan Tambahan (Opsional)',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 32),

              // Tombol Submit
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _submitPesanan();
                        }
                      },
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Konfirmasi Pesanan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
