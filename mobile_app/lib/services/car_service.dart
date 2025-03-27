// lib/services/car_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CarService {
  final String _baseUrl = 'http://10.0.2.2:5000/api';  // Pour émulateur Android

  Future<Map<String, dynamic>> addCar(String make, String model, int year) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/car'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'make': make,
          'model': model,
          'year': year
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error']);
      }
    } catch (e) {
      throw Exception('Failed to add car: $e');
    }
  }

  Future<List<dynamic>> getUserCars() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/cars/$userId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load cars');
      }
    } catch (e) {
      throw Exception('Failed to fetch cars: $e');
    }
  }

  Future<List<dynamic>> getMaintenanceRecords(int carId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/car/maintenance/$carId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load maintenance records');
      }
    } catch (e) {
      throw Exception('Failed to fetch maintenance records: $e');
    }
  }

  Future<void> addMaintenanceRecord(Map<String, dynamic> maintenanceData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/car/maintenance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(maintenanceData),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add maintenance record');
      }
    } catch (e) {
      throw Exception('Failed to add maintenance record: $e');
    }
  }
}