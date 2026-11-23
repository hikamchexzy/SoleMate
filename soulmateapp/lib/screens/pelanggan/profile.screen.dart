import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Wajib untuk inputFormatters
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth.service.dart';

class ProfilScreen extends StatefulWidget {
  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _authService = AuthService();
  final _picker = ImagePicker();

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController(); // <-- Controller No HP

  String? _fotoProfilUrl;
  File? _fotoBaru;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaController.text = prefs.getString('nama') ?? 'Pelanggan';
      _emailController.text = prefs.getString('email') ?? '';
      _noHpController.text = prefs.getString('no_hp') ?? ''; // Ambil No HP
      _fotoProfilUrl = prefs.getString('foto_profil');
    });
  }

  // Fungsi untuk memunculkan pilihan Kamera / Galeri
  void _pilihFoto() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _ambilFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.green),
              title: Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _ambilFoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _ambilFoto(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() => _fotoBaru = File(picked.path));
    }
  }

  // Fungsi Simpan Profil (Hanya satu, tidak dobel)
  void _simpanProfil() async {
    setState(() => _isLoading = true);

    // Panggil fungsi simpanProfil dari service yang sudah kita gabungkan
    final success = await _authService.simpanProfil(
      nama: _namaController.text,
      noHp: _noHpController.text,
      fotoBaru: _fotoBaru,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil berhasil diperbarui!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui profil.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil Saya')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Tampilan Foto Profil
            GestureDetector(
              onTap: _pilihFoto,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _fotoBaru != null
                    ? FileImage(_fotoBaru!) as ImageProvider
                    : (_fotoProfilUrl != null
                          ? NetworkImage(_fotoProfilUrl!)
                          : null),
                child: (_fotoBaru == null && _fotoProfilUrl == null)
                    ? Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Klik foto untuk mengubah',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            SizedBox(height: 32),

            // Form Nama
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),

            // Form Email (Readonly)
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            SizedBox(height: 16),

            // Form Nomor HP (Baru)
            TextField(
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
            ),

            SizedBox(height: 32),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanProfil,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}