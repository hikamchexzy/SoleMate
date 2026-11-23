import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.config.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['data']['user'];
        final token = data['data']['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', user['role']);
        await prefs.setString('nama', user['nama']); // <-- Simpan Nama
        await prefs.setString('email', user['email']); // <-- Simpan Email
        if (user['foto_profil'] != null) {
          await prefs.setString(
            'foto_profil',
            user['foto_profil'],
          ); // <-- Simpan Foto (jika ada)
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> simpanProfil({
    required String nama,
    required String noHp,
    File? fotoBaru,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['nama'] = nama;
      request.fields['no_hp'] = noHp;

      // Jika ada foto baru, masukkan ke form-data
      if (fotoBaru != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto_profil', fotoBaru.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Simpan nama & no hp ke lokal (SharedPreferences)
        await prefs.setString('nama', nama);
        await prefs.setString('no_hp', noHp);

        // Jika response mengembalikan URL foto baru, simpan
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['foto_profil'] != null) {
          await prefs.setString('foto_profil', data['data']['foto_profil']);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error simpan profil: $e');
      return false;
    }
  }
}
