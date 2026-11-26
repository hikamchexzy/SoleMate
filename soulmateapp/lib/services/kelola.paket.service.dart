import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.config.dart';

class KelolaPaketService {
  // 1. Ambil semua paket

  Future<List<dynamic>> getAllPaket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/paket'),
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

  // 2. Tambah Paket Baru
  Future<bool> tambahPaket({
    required String nama,
    required String deskripsi,
    required int harga,
    required int estimasiHari,
    File? gambar,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/paket'));
      request.headers['Authorization'] = 'Bearer $token';
      
      request.fields['nama_paket'] = nama;
      request.fields['deskripsi'] = deskripsi;
      request.fields['harga'] = harga.toString();
      request.fields['estimasi_hari'] = estimasiHari.toString();

      if (gambar != null) {
        request.files.add(await http.MultipartFile.fromPath('gambar', gambar.path));
      }

      final streamedResponse = await request.send();
      return streamedResponse.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 3. Edit Paket
  Future<bool> editPaket({
    required int id,
    required String nama,
    required String deskripsi,
    required int harga,
    required int estimasiHari,
    File? gambar,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = http.MultipartRequest('PUT', Uri.parse('${ApiConfig.baseUrl}/paket/$id'));
      request.headers['Authorization'] = 'Bearer $token';
      
      request.fields['nama_paket'] = nama;
      request.fields['deskripsi'] = deskripsi;
      request.fields['harga'] = harga.toString();
      request.fields['estimasi_hari'] = estimasiHari.toString();

      if (gambar != null) {
        request.files.add(await http.MultipartFile.fromPath('gambar', gambar.path));
      }

      final streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 4. Hapus Paket (Soft Delete)
  Future<bool> hapusPaket(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/paket/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}