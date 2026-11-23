import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.config.dart';

class KelolaPesananService {
  // 1. Ambil semua pesanan (Admin melihat semua)
  Future<List<dynamic>> getAllPesanan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/pesanan'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return [];
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // 2. Ubah status pesanan
  Future<bool> updateStatus(int pesananId, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/pesanan/$pesananId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': newStatus}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 3. Upload Foto Before / After
  Future<bool> uploadFoto(int pesananId, String tipe, File foto) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}/pesanan/$pesananId/foto'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['tipe'] = tipe; // 'before' atau 'after'
      request.files.add(await http.MultipartFile.fromPath('foto', foto.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}