import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/dashboard.service.dart';
import 'kelola.pesanan.screen.dart';
import 'kelola.paket.screen.dart';
import '../login.screen.dart'; // Sesuaikan dengan nama file loginmu

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  late Future<Map<String, dynamic>> _futureStatistik;
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _futureStatistik = _dashboardService.getStatistik();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _futureStatistik,
          builder: (context, snapshot) {
            // Tampilan Header
            Widget header = Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SoleMate Admin',
                        style: GoogleFonts.urbanist(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Selamat datang kembali, Bos!',
                        style: GoogleFonts.urbanist(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.red),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            );

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  header,
                  Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              );
            } else if (snapshot.hasError) {
              return Column(
                children: [
                  header,
                  Expanded(
                    child: Center(
                      child: Text('Gagal memuat data: ${snapshot.error}'),
                    ),
                  ),
                ],
              );
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,

                  // 1. KARTU STATISTIK (GRID)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Pendapatan',
                            currencyFormatter.format(
                              data['total_pendapatan'] ?? 0,
                            ),
                            Icons.account_balance_wallet,
                            Color(0xFFFDE68A), // Kuning Pastel
                            Colors.black87,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Sedang Dicuci',
                            '${data['sedang_dicuci'] ?? 0} Psn',
                            Icons.local_laundry_service,
                            Colors.blue[100]!, 
                            Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // 2. MENU PENGELOLAAN
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Menu Pengelolaan',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Card Menu Kelola Pesanan
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8,
                    ),
                    child: _buildMenuCard(
                      title: 'Kelola Pesanan',
                      subtitle: 'Update status & upload foto sepatu',
                      icon: Icons.receipt_long,
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KelolaPesananScreen(),
                        ),
                      ),
                    ),
                  ),

                  // Card Menu Kelola Paket
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8,
                    ),
                    child: _buildMenuCard(
                      title: 'Kelola Paket Layanan',
                      subtitle: 'Tambah, edit, atau hapus layanan',
                      icon: Icons.inventory_2,
                      color: Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => KelolaPaketScreen()),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget untuk Kartu Statistik
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 32),
          SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.urbanist(
              color: textColor.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.urbanist(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Menu Card
  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
