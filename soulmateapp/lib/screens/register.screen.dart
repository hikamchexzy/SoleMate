import 'package:flutter/material.dart';
import '../services/auth.service.dart';

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
      // Jika sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
      );
      Navigator.pop(context); // Kembali ke halaman Login
    } else {
      // Jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Akun Baru')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bergabung dengan SoleMate',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),
              
              // Input Nama
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              SizedBox(height: 16),

              // Input Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) {
                  if (val!.isEmpty) return 'Email tidak boleh kosong';
                  if (!val.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Input No HP
              TextFormField(
                controller: _noHpController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nomor HP / WhatsApp',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) => val!.isEmpty ? 'Nomor HP tidak boleh kosong' : null,
              ),
              SizedBox(height: 16),

              // Input Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
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
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white) 
                  : Text('Daftar Sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}