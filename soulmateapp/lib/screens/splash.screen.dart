import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.screen.dart'; // Sesuaikan path-nya dengan nama file loginmu

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Pindah ke halaman login setelah 2.5 detik
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final logoSize = (screenSize.shortestSide * 0.30).clamp(96.0, 180.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'S',
              style: GoogleFonts.urbanist(
                fontSize: logoSize,
                height: 1,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 24),

            // Teks Logo
            Text(
              'SoleMate',
              style: GoogleFonts.urbanist(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Teman Cuci Sepatu Anda',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
