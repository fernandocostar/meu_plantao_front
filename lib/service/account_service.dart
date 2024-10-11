import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:meu_plantao_front/screens/auth/enums/ProfessionalTypeEnum.dart';
import 'package:meu_plantao_front/screens/common/state_city_provider.dart'
    as state_city_provider;

class AccountService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final state_city_provider.StateCityProvider _stateCityProvider =
      state_city_provider.StateCityProvider();

  Future<Map<String, dynamic>?> fetchAccountInfo() async {
    try {
      String? token = await _secureStorage.read(key: 'token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('http://localhost:3000/account/info'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          throw Exception('Failed to load account information.');
        }
      } else {
        throw Exception('Token not found.');
      }
    } catch (e) {
      print('Error fetching account info: $e');
      throw Exception('An error occurred while fetching account information.');
    }
  }

  Future<void> updateAccountInfo({
    required String name,
    required String professionalRegister,
    required String professionalType,
    required String state,
    required String city,
  }) async {
    try {
      String? token = await _secureStorage.read(key: 'token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('http://localhost:3000/account/update'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': name,
            'professionalRegister': professionalRegister,
            'professionalType': ProfessionalType.values
                .firstWhere((type) => type.label == professionalType)
                .index,
            'state': state,
            'city': city,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to update account information.');
        }
      } else {
        throw Exception('Token not found.');
      }
    } catch (e) {
      print('Error updating account info: $e');
      throw Exception('An error occurred while updating account information.');
    }
  }

  Future<Map<String, dynamic>?> searchUserByPhone(String phoneNumber) async {
    try {
      String? token = await _secureStorage.read(key: 'token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('http://localhost:3000/account/searchByPhone?phone=$phoneNumber'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 404) {
          return null;
        } else {
          throw Exception('Failed to search account by phone.');
        }
      } else {
        throw Exception('Token not found.');
      }
    } catch (e) {
      print('Error searching account by phone: $e');
      throw Exception('An error occurred while searching account by phone.');
    }
  }

}
