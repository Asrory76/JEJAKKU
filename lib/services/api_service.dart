import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../lanjutan.dart';

class ApiService {
  // Base URL otomatis mendeteksi platform
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    try {
      if (Platform.isAndroid) {
        // 10.0.2.2 mengarah ke localhost host machine di Android Emulator
        return 'http://10.0.2.2:3000';
      }
    } catch (_) {}
    return 'http://localhost:3000';
  }

  static String baseUrl = defaultBaseUrl;

  // Session Token & User
  static String? token;
  static Map<String, dynamic>? currentUser;

  // Helper Header
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ==========================================
  // AUTHENTICATION
  // ==========================================

  // POST /api/auth/login

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username.trim(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      token = data['token'];
      currentUser = data['user'];
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login gagal. Periksa username dan password.');
    }
  }

  // POST /api/auth/register
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? name,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
        'name': name?.trim() ?? username.trim(),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Registrasi gagal.');
    }
  }

  // ==========================================
  // VEHICLE MANAGEMENT
  // ==========================================

  // GET /api/vehicles
  static Future<List<Vehicle>> getVehicles() async {
    final url = Uri.parse('$baseUrl/api/vehicles');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['vehicles'] is List) {
        return (data['vehicles'] as List)
            .map((item) => Vehicle.fromJson(item))
            .toList();
      }
    }
    throw Exception('Gagal memuat data kendaraan dari server');
  }

  // POST /api/vehicles
  static Future<Vehicle> addVehicle({
    required String name,
    required String plate,
    required bool isMotor,
    String status = 'connected',
  }) async {
    final url = Uri.parse('$baseUrl/api/vehicles');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'name': name.trim(),
        'plate': plate.trim().toUpperCase(),
        'isMotor': isMotor,
        'status': status,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return Vehicle.fromJson(data['vehicle']);
    } else {
      throw Exception(data['message'] ?? 'Gagal menambahkan kendaraan');
    }
  }

  // DELETE /api/vehicles/:id
  static Future<bool> deleteVehicle(int id) async {
    final url = Uri.parse('$baseUrl/api/vehicles/$id');
    final response = await http.delete(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  // ==========================================
  // GPS TRACKING
  // ==========================================

  // GET /api/positions/:vehicleId
  static Future<Map<String, dynamic>?> getLatestPosition(int vehicleId) async {
    final url = Uri.parse('$baseUrl/api/positions/$vehicleId');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['position'];
      }
    }
    return null;
  }

  // GET /api/positions/:vehicleId/history
  static Future<List<Map<String, dynamic>>> getPositionHistory(
    int vehicleId, {
    int limit = 50,
  }) async {
    final url = Uri.parse('$baseUrl/api/positions/$vehicleId/history?limit=$limit');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['history'] is List) {
        return List<Map<String, dynamic>>.from(data['history']);
      }
    }
    return [];
  }

  // POST /api/positions
  static Future<bool> updatePosition({
    required int vehicleId,
    required double lat,
    required double lng,
    String? address,
  }) async {
    final url = Uri.parse('$baseUrl/api/positions');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'vehicleId': vehicleId,
        'lat': lat,
        'lng': lng,
        'address': address,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    }
    return false;
  }
}
