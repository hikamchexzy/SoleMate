import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/dashboard.service.dart';
import 'kelola.pesanan.screen.dart';
import 'kelola.paket.screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  late Future<Map<String, dynamic>> _futureStatistik;
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _futureStatistik = _dashboardService.getStatistik();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Logout: Kembali ke halaman login
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureStatistik,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kartu Statistik
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Pendapatan',
                        currencyFormatter.format(data['total_pendapatan'] ?? 0),
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Sedang Dicuci',
                        '${data['sedang_dicuci'] ?? 0} Pesanan',
                        Icons.local_laundry_service,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Menu Navigasi
                Text('Menu Pengelolaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.receipt_long, color: Colors.orange),
                    title: Text('Kelola Pesanan'),
                    subtitle: Text('Lihat pesanan masuk, update status, upload foto'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => KelolaPesananScreen()));
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.inventory_2, color: Colors.purple),
                    title: Text('Kelola Paket Layanan'),
                    subtitle: Text('Tambah, edit, atau hapus paket cuci sepatu'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => KelolaPaketScreen()));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 8),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}