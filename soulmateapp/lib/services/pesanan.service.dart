import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.config.dart';
import '../models/paket.model.dart';

class PesananService {
  Future<List<dynamic>> getRiwayatPesanan() async {
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

  Future<bool> buatPesanan({
    required int paketId,
    required File fotoSepatu,
    required String noHpKontak,
    required String tingkatKekotoran,
    String? catatan,
    required int totalHarga,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/pesanan'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      
      request.fields['paket_id'] = paketId.toString();
      request.fields['no_hp_kontak'] = noHpKontak;
      request.fields['tingkat_kekotoran'] = tingkatKekotoran;
      request.fields['total_harga'] = totalHarga.toString();
      
      if (catatan != null && catatan.isNotEmpty) {
        request.fields['catatan'] = catatan;
      }

      request.files.add(
        await http.MultipartFile.fromPath('foto_sepatu', fotoSepatu.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}