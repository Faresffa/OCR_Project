// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  final String _baseUrl = 'http://10.0.2.2:5000/api';  // Pour émulateur Android

  Future<Map<String, dynamic>> signup(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.signupUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Sauvegarder les informations de l'utilisateur
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', data['user']['email']);
        await prefs.setInt('user_id', data['user']['id']);
        return data;
      } else {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Sauvegarder les informations de l'utilisateur
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', data['user']['email']);
        await prefs.setInt('user_id', data['user']['id']);
        return data;
      } else {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_id');
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
}