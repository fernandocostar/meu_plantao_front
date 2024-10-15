import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShiftPassService {
  final String apiUrl = 'http://10.0.2.2:8080/shifts/pass';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Busca todas as passagens de plantões oferecidas ao usuário atual
  Future<List<dynamic>> fetchOfferedShifts() async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/get/offeredShifts'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch offered shift passes: ${response.body}');
    }
  }

  // Aceita uma passagem de plantão com o ID da localização selecionada
  Future<void> acceptShiftPass(int shiftPassId, int locationId) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.post(
      Uri.parse('$apiUrl/accept/$shiftPassId?locationId=$locationId'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept shift pass: ${response.body}');
    }
  }

  // Método para rejeitar um plantão pode ser adicionado aqui se necessário
  Future<void> createShiftPass({
    required int shiftId,
    required List<String>
        offeredUsers, // Lista de IDs dos usuários para quem o plantão é oferecido
  }) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.post(
      Uri.parse('$apiUrl/create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'shiftId': shiftId
            .toString(), // O shiftId deve ser convertido para string conforme o exemplo do curl
        'offeredUsers': offeredUsers,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create shift pass: ${response.body}');
    }
  }

  Future<void> editShiftPass({
    required int shiftPassId,
    required List<String>
        offeredUsers, // Lista de IDs dos novos usuários oferecidos
  }) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.put(
      Uri.parse('$apiUrl/edit/$shiftPassId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'offeredUsers': offeredUsers, // Enviando a nova lista de offeredUsers
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit shift pass: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> shiftPassExists(int shiftId) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/get/').replace(
        queryParameters: {
          'originShiftId': shiftId.toString(),
        },
      ),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody.isNotEmpty) {
        return responseBody; // Retorna os detalhes do shift pass se existir
      } else {
        return {}; // Retorna um map vazio se não existir shift pass
      }
    } else if (response.statusCode == 404) {
      return {}; // Retorna um map vazio se não existir shift pass
    } else {
      throw Exception('Failed to check shift pass existence: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchOfferedUsers(int shiftPassId) async {
    final String? authToken = await _secureStorage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Auth token is not available');
    }

    log('fetchOfferedUsers');

    final response = await http.get(
      Uri.parse('$apiUrl/get/$shiftPassId'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    log('fetchOfferedUsers response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody != null) {
        log('returning offered users');
        return responseBody; // Retorna a lista de usuários oferecidos
      } else {
        throw Exception('No offered users found');
      }
    } else {
      throw Exception('Failed to fetch shift pass details: ${response.body}');
    }
  }
}
