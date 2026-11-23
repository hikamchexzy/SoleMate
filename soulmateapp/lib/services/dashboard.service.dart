import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.config.dart';

class DashboardService {
  Future<Map<String, dynamic>> getStatistik() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Gagal mengambil statistik');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}