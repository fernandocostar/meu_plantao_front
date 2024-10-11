import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShiftPassService {
  final String apiUrl = 'http://localhost:3000/shiftpasses';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> createShiftPass({
    required int shiftId,
    required List<int> assignedUsers,
  }) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.post(
      Uri.parse('$apiUrl/createShiftPass'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'shiftId': shiftId,
        'assignedUsers': assignedUsers,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create shift pass: ${response.body}');
    }
  }

  Future<void> editShiftPass({
    required int shiftId,
    required List<int> assignedUsers,
  }) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.put(
      Uri.parse('$apiUrl/updateShiftPass/$shiftId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'assignedUsers': assignedUsers,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit shift pass: ${response.body}');
    }
  }

  Future<void> deleteShiftPass(int? id) async {
    final String? authToken = await _secureStorage.read(key: 'token');

    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response =
        await http.delete(Uri.parse('$apiUrl/deleteShiftPass/$id'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to delete shift pass: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchAllShiftPasses() async {
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
      throw Exception('Failed to fetch shift passes: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchCurrentMonthShiftPasses() async {
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
      List<dynamic> shiftPasses = jsonDecode(response.body);

      // Filter shift passes to include only those within the current month
      DateTime now = DateTime.now();
      int currentMonth = now.month;
      int currentYear = now.year;

      shiftPasses = shiftPasses.where((shiftPass) {
        DateTime start = DateTime.parse(shiftPass['startTime']);
        return start.month == currentMonth && start.year == currentYear;
      }).toList();

      // Sort by start time
      shiftPasses.sort((a, b) => DateTime.parse(a['startTime'])
          .compareTo(DateTime.parse(b['startTime'])));
      return shiftPasses;
    } else {
      throw Exception('Failed to fetch shift passes: ${response.body}');
    }
  }

  Future<List<dynamic>> getAssignedUsers(int shiftId) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/getAssignedUsers/$shiftId'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['users'];
    } else {
      throw Exception('Failed to fetch assigned users: ${response.body}');
    }
  }

  Future<bool> checkShiftPassExists(int id) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/checkPassExists/$id'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['exists'] as bool;
    } else {
      throw Exception('Failed to check if passage exists: ${response.body}');
    }
  }

}