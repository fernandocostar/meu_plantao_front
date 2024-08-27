import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:meu_plantao_front/service/auth_service.dart';
import 'package:meu_plantao_front/screens/auth/components/auth_submit_button.dart';
import 'package:meu_plantao_front/screens/auth/components/auth_text_field.dart';
import 'package:meu_plantao_front/screens/auth/AuthValidators.dart';
import 'package:meu_plantao_front/util/constants.dart';

import '../calendar/calendar_page.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final secureStorage = const FlutterSecureStorage();

  Future<void> signUserIn(BuildContext context) async {
    final AuthService authService = AuthService(
      showErrorDialog: (message) => _showErrorDialog(context, message),
      navigateToHomePage: (responseData) =>
          navigateToHomePage(context, responseData),
    );

    authService.signUserIn(
      emailController.text,
      passwordController.text,
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 180),
                  Image.asset(ConstImages.mainLogo, height: 120),
                  const SizedBox(height: 50),
                  Text(
                    'Vamos começar a organizar sua rotina!',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthTextField(
                    controller: emailController,
                    hintText: 'E-mail',
                    obscureText: false,
                    validator: FormValidators.validateEmail,
                  ),
                  const SizedBox(height: 15),
                  AuthTextField(
                    controller: passwordController,
                    hintText: 'Senha',
                    obscureText: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Esqueceu sua senha?',
                          style:
                              TextStyle(color: Colors.grey[800], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35.0),
                  AuthSubmitButton(
                      onTap: () => signUserIn(context),
                      text: 'Entrar' // Passando o contexto
                      ),
                  const SizedBox(height: 40.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não possui uma conta? ',
                        style: TextStyle(color: Colors.grey[800], fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          navigateToRegisterPage(context);
                        },
                        child: Text(
                          'Cadastre-se já!',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void navigateToHomePage(
      BuildContext context, Map<String, dynamic> responseData) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarPage(
          name: responseData['name'],
          email: responseData['email'],
          token: responseData['token'],
          onQuit: () {
            removeToken();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
    );
  }

  void navigateToRegisterPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(),
      ),
    );
  }

  void storeToken(String token) async {
    await secureStorage.write(
      key: 'token',
      value: token,
    );
  }

  void storeUserName(String userName) async {
    await secureStorage.write(key: 'name', value: userName);
  }

  void storeEmail(String email) async {
    await secureStorage.write(key: 'email', value: email);
  }

  void removeToken() async {
    await secureStorage.delete(key: 'token');
  }
}
