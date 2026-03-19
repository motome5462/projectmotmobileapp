// lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  Map<String, dynamic>? _userData;
  int? _logId;

  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get user => _userData;

  // ฟังก์ชัน Login เชื่อมต่อกับ Express API
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://your-api-url:3000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userData = data['user'];
        _logId = data['log_id'];

        // เก็บ Token ไว้ใน Secure Storage
        await _storage.write(key: 'jwt_token', value: _token);
        await _storage.write(key: 'log_id', value: _logId.toString());
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  // ฟังก์ชัน Logout และอัปเดต Logout Log ใน DB
  Future<void> logout() async {
    if (_logId != null) {
      await http.post(
        Uri.parse('http://your-api-url:3000/api/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'log_id': _logId}),
      );
    }
    _token = null;
    _userData = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}