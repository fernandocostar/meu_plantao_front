import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  final String apiUrl = 'http://10.0.2.2:3000/locations';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<List<dynamic>> fetchAllActiveLocations() async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/getUserLocations'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch locations: ${response.body}');
    }
  }

  Future<void> createLocation({
    required String name,
  }) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.post(
      Uri.parse('$apiUrl/createLocation'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'name': name,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create location: ${response.body}');
    }
  }

  Future<void> updateLocation({
    required String id,
    required String name,
  }) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.post(
      Uri.parse('$apiUrl/updateLocation/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'name': name,
      }),
    );

    print(response.statusCode);

    if (response.statusCode != 200) {
      throw Exception('Failed to update location: ${response.body}');
    }
  }

  Future<void> deleteLocation(String id) async {
    print(id);
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.delete(
      Uri.parse('$apiUrl/deleteLocation/$id'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete location: ${response.body}');
    }
  }
}
