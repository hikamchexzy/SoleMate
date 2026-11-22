import 'package:flutter/material.dart';

class PelangganHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beranda Pelanggan')),
      body: Center(
        child: Text('Halaman Daftar Paket untuk Pelanggan'),
      ),
    );
  }
}