import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth.service.dart'; // Sesuaikan path

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noHpController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final errorMessage = await _authService.register(
      _namaController.text,
      _emailController.text,
      _passwordController.text,
      _noHpController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
      );
      Navigator.pop(context); // Kembali ke halaman Login
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar putih bersih untuk form
      appBar: AppBar(title: Text('Buat Akun'), backgroundColor: Colors.white),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Teks
                Text(
                  'Bergabung dengan\nSoleMate',
                  style: GoogleFonts.urbanist(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Isi data diri kamu untuk mulai menikmati layanan cuci sepatu premium.',
                  style: GoogleFonts.urbanist(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 32),

                // Form Nama
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                SizedBox(height: 16),

                // Form Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (val) {
                    if (val!.isEmpty) return 'Email tidak boleh kosong';
                    if (!val.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Form No HP
                TextFormField(
                  controller: _noHpController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor HP / WhatsApp',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Nomor HP tidak boleh kosong' : null,
                ),
                SizedBox(height: 16),

                // Form Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (val) {
                    if (val!.isEmpty) return 'Password tidak boleh kosong';
                    if (val.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                SizedBox(height: 32),

                // Tombol Daftar
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Daftar Sekarang'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
