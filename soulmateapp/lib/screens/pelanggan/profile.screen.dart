import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Wajib untuk inputFormatters
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth.service.dart';
import '../login.screen.dart';

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
    await _authService.getProfil();
    if (!mounted) return;

    final updatedPrefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _namaController.text = updatedPrefs.getString('nama') ?? 'Pelanggan';
      _emailController.text = updatedPrefs.getString('email') ?? '';
      _noHpController.text =
          updatedPrefs.getString('no_hp') ?? ''; // Ambil No HP
      _fotoProfilUrl = updatedPrefs.getString('foto_profil');
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
              leading: Icon(Icons.camera_alt, color: Colors.black),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profil berhasil diperbarui!')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui profil.')));
    }
  }

  void _logout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Konfirmasi Logout'),
        content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (!mounted || !dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil Saya')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Foto Profil
            GestureDetector(
              onTap: _pilihFoto,
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _fotoBaru != null
                            ? FileImage(_fotoBaru!) as ImageProvider
                            : (_fotoProfilUrl != null
                                  ? NetworkImage(_fotoProfilUrl!)
                                  : null),
                        child: (_fotoBaru == null && _fotoProfilUrl == null)
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.black87,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            // Form Nama
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            SizedBox(height: 16),

            // Form Email (Readonly)
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                fillColor: Colors.grey[200], // Lebih gelap karena readonly
              ),
            ),
            SizedBox(height: 16),

            // Form Nomor HP
            TextField(
              controller: _noHpController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(14),
              ],
              decoration: InputDecoration(
                labelText: 'Nomor HP / WhatsApp',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            SizedBox(height: 32),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanProfil,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Simpan Perubahan'),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'Logout Akun',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
