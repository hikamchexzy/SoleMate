import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash.screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const Color softBlueBg = Color(0xFFF5F5F5);
    const Color deepNavy = Colors.black;
    const Color accentAmber = Color(0xFFF59E0B);
    const Color inputFill = Color(0xFFFFFFFF);

    return MaterialApp(
      title: 'SoleMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: softBlueBg,
        colorScheme: ColorScheme.light(
          primary: deepNavy,
          secondary: accentAmber,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.urbanistTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: deepNavy, displayColor: deepNavy),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: deepNavy),
          titleTextStyle: GoogleFonts.urbanist(
            color: deepNavy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: deepNavy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.urbanist(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            elevation: 0,
          ),
        ),
        // --- STYLING GLOBAL UNTUK FORM INPUT ---
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputFill,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: GoogleFonts.urbanist(color: Colors.grey[400]),
          labelStyle: GoogleFonts.urbanist(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: deepNavy, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
        ),
        // --- STYLING GLOBAL UNTUK BOTTOM SHEET ---
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: softBlueBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
        ),
        // --- STYLING GLOBAL UNTUK DIALOG ---
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
