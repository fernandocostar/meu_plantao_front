import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShiftService {
  final String apiUrl = 'http://10.0.2.2:8080/shifts';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> createShift({
    DateTime? startDate,
    DateTime? endDate,
    double? value,
    String? location,
  }) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.post(
      Uri.parse('$apiUrl/createShift'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'startTime': startDate?.toIso8601String(),
        'endTime': endDate?.toIso8601String(),
        'value': value,
        'location': location,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create shift: ${response.body}');
    }
  }

  Future<void> editShift({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    double? value,
    String? location,
  }) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.post(
      Uri.parse('$apiUrl/updateShift/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'startTime': startDate?.toIso8601String(),
        'endTime': endDate?.toIso8601String(),
        'value': value,
        'location': location,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit shift: ${response.body}');
    }
  }

  Future<void> deleteShift(int? id) async {
    final String? authToken = await _secureStorage.read(key: 'token');

    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response =
        await http.delete(Uri.parse('$apiUrl/deleteShift/$id'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to delete shift: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchAllShifts() async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/getAll'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch shifts: ${response.body}');
    }
  }
}
