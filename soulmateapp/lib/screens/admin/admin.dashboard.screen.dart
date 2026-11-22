import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Pemilik')),
      body: Center(
        child: Text('Halaman Statistik & Kelola Pesanan untuk Admin'),
      ),
    );
  }
}