import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final double padding = 25.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600, // Constrain max width to ensure it looks good on larger screens
              ),
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.13),
                  Image.asset(
                    ConstImages.mainLogo,
                    height: screenSize.height * 0.12, // Adjust logo size based on screen height
                  ),
                  SizedBox(height: screenSize.height * 0.05),
                  Text(
                    'Vamos começar a organizar sua rotina!',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  AuthTextField(
                    controller: emailController,
                    hintText: 'E-mail',
                    obscureText: false,
                    validator: FormValidators.validateEmail,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  AuthTextField(
                    controller: passwordController,
                    hintText: 'Senha',
                    obscureText: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Esqueceu sua senha?',
                        style: TextStyle(color: Colors.grey[800], fontSize: 14),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.05),
                  AuthSubmitButton(
                    onTap: () => signUserIn(context),
                    text: 'Entrar',
                  ),
                  SizedBox(height: screenSize.height * 0.05),
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
