import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String apiUrl =
      'http://localhost:3000/auth';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final http.Client _client = http.Client();

  final void Function(String) showErrorDialog;
  final void Function(Map<String, dynamic>) navigateToHomePage;

  AuthService({
    required this.showErrorDialog,
    required this.navigateToHomePage,
  });

  Future<void> signUserIn(String email, String password) async {
    if (_areCredentialsEmpty(email, password)) {
      showErrorDialog('Por favor, preencha todos os campos.');
      return;
    }

    final body = _createLoginBody(email, password);

    try {
      final response = await _postRequest('$apiUrl/login', body);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final responseData = json.decode(response.body);
        await _storeUserData(responseData);
        navigateToHomePage(responseData);
      } else {
        final errorMessage = _extractErrorMessage(response);
        showErrorDialog(errorMessage);
      }
    } catch (error) {
      showErrorDialog(
          'Falha ao se conectar ao servidor. Tente novamente mais tarde.');
    }
  }

  Future<void> signUpUser(
    String email,
    String password,
    String name,
    int professionalType,
    String professionalRegister,
    String state,
    String city,
  ) async {
    if (_areCredentialsEmpty(email, password)) {
      showErrorDialog('Por favor, preencha todos os campos.');
      return;
    }

    final body = _createSignUpBody(
      email,
      password,
      name,
      professionalType,
      professionalRegister,
      state,
      city,
    );

    try {
      final response = await _postRequest('$apiUrl/register', body);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final responseData = json.decode(response.body);
        await _storeUserData(responseData);
        navigateToHomePage(responseData);
      } else {
        final errorMessage = _extractErrorMessage(response);
        showErrorDialog(errorMessage);
      }
    } catch (error) {
      showErrorDialog(
          'Falha ao se conectar ao servidor. Tente novamente mais tarde.');
    }
  }

  Future<void> storeToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
  }

  Future<void> storeUserName(String userName) async {
    await _secureStorage.write(key: 'name', value: userName);
  }

  Future<void> storeEmail(String email) async {
    await _secureStorage.write(key: 'email', value: email);
  }

  Future<void> removeToken() async {
    await _secureStorage.delete(key: 'token');
  }

  bool _areCredentialsEmpty(String email, String password) {
    return email.isEmpty || password.isEmpty;
  }

  Map<String, dynamic> _createLoginBody(String email, String password) {
    return {
      'email': email,
      'password': password,
    };
  }

  Map<String, dynamic> _createSignUpBody(
    String email,
    String password,
    String name,
    int professionalType,
    String professionalRegister,
    String state,
    String city,
  ) {
    return {
      'email': email,
      'password': password,
      'name': name,
      'professionalType': professionalType,
      'professionalRegister': professionalRegister,
      'state': state,
      'city': city,
    };
  }

  Future<http.Response> _postRequest(
      String url, Map<String, dynamic> body) async {
    return await _client.post( // Use _client instead of http
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  Future<void> _storeUserData(Map<String, dynamic> data) async {
    await Future.wait([
      storeToken(data['token']),
      storeEmail(data['email']),
      storeUserName(data['name']),
    ]);
  }

  String _extractErrorMessage(http.Response response) {
    return json.decode(response.body)['error'] ??
        'Falha ao se conectar ao servidor. Tente novamente mais tarde.' +
            response.statusCode.toString();
  }
}
