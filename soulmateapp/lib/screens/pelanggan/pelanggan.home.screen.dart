import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/paket.service.dart';
import '../../models/paket.model.dart';
import 'buat.pesanan.screen.dart';
import 'riwayat.pesanan.screen.dart';
import 'profile.screen.dart'; // Pastikan nama file ini sesuai dengan yang ada di foldermu

class PelangganHomeScreen extends StatefulWidget {
  @override
  _PelangganHomeScreenState createState() => _PelangganHomeScreenState();
}

class _PelangganHomeScreenState extends State<PelangganHomeScreen> {
  final PaketService _paketService = PaketService();
  late Future<List<Paket>> _futurePaket;
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // --- STATE UNTUK FITUR SEARCH ---
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futurePaket = _paketService.getPaket();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ==========================================
            // 1. HEADER (LOGO, NAVIGASI, & SEARCH)
            // ==========================================
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Atas: Logo SoleMate & Navigasi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 8),
                            Text(
                              'SoleMate',
                              style: GoogleFonts.urbanist(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        // Navigasi Kanan (Riwayat & Profil)
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.history, color: Colors.black87),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RiwayatPesananScreen(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.person_outline,
                                color: Colors.black87,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfilScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Teks Sapaan & Pencarian
                    Text(
                      'Mau cuci sepatu\napa hari ini?',
                      style: GoogleFonts.urbanist(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 16),

                    // FITUR SEARCH
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari layanan (Fast Clean, dll)...',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // 2. JUDUL BAGIAN PAKET
            // ==========================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  'Layanan Terbaik Kami',
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ==========================================
            // 3. LIST PAKET (DENGAN FILTER SEARCH)
            // ==========================================
            FutureBuilder<List<Paket>>(
              future: _futurePaket,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Belum ada layanan.'),
                      ),
                    ),
                  );
                }

                // LOGIKA FILTER SEARCH
                final filteredPaket = snapshot.data!.where((paket) {
                  return paket.namaPaket.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredPaket.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Paket tidak ditemukan.'),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final paket = filteredPaket[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Gambar Paket
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: paket.gambar != null
                                    ? Image.network(
                                        paket.gambar!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  color: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                      )
                                    : Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.black54,
                                        ),
                                      ),
                              ),
                              SizedBox(width: 16),
                              // Info Paket
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paket.namaPaket,
                                      style: GoogleFonts.urbanist(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      paket.deskripsi,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.urbanist(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          currencyFormatter.format(paket.harga),
                                          style: GoogleFonts.urbanist(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    BuatPesananScreen(
                                                      paket: paket,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Color(
                                                0xFFF59E0B,
                                              ), // Tombol oranye
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }, childCount: filteredPaket.length),
                );
              },
            ),

            SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
