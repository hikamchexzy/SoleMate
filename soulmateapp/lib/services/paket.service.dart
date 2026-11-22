import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.config.dart';
import '../models/paket.model.dart';

class PaketService {
  Future<List<Paket>> getPaket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/paket'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> listPaket = data['data'];
        
        // Ubah list JSON menjadi List Objek Paket
        return listPaket.map((json) => Paket.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat paket');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}