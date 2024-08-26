import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:meu_plantao_front/service/auth_service.dart';
import 'package:meu_plantao_front/screens/auth/components/auth_submit_button.dart';
import 'package:meu_plantao_front/screens/auth/components/auth_text_field.dart';
import 'package:meu_plantao_front/screens/auth/components/dropdown.dart';
import 'package:meu_plantao_front/screens/auth/enums/ProfessionalTypeEnum.dart';
import 'package:meu_plantao_front/screens/auth/AuthValidators.dart';
import 'package:meu_plantao_front/util/constants.dart';
import 'package:meu_plantao_front/screens/common/state_city_provider.dart'
    as state_city_provider;

import '../home/home_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final stateCityProvider = state_city_provider.StateCityProvider();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final professionalRegisterController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  ValueNotifier<String?> professionalTypeController =
      ValueNotifier<String?>(null);
  ValueNotifier<String?> stateController = ValueNotifier<String?>(null);
  ValueNotifier<String?> cityController = ValueNotifier<String?>(null);

  List<String> professionalTypes =
      ProfessionalType.values.map((type) => type.label).toList();
  List<String> estados = [];
  List<String> cidades = [];

  final secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadInitialStateData();
  }

  Future<void> loadInitialStateData() async {
    await stateCityProvider.loadStateAndCityData();
    setState(() {
      estados = stateCityProvider.getStateNames();
    });
  }

  Future<void> signUpUser(BuildContext context) async {
    final AuthService authService = AuthService(
      showErrorDialog: (message) => _showErrorDialog(context, message),
      navigateToHomePage: (responseData) =>
          navigateToHomePage(context, responseData),
    );

    authService.signUpUser(
      emailController.text,
      passwordController.text,
      nameController.text,
      ProfessionalType.values
          .firstWhere((type) => type.label == professionalTypeController.value!)
          .index,
      professionalRegisterController.text,
      stateController.value!,
      cityController.value!,
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro'),
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
                  const SizedBox(height: 30),
                  Image(image: AssetImage(ConstImages.mainLogo), height: 70),
                  const SizedBox(height: 30),
                  Text(
                    'Primeira vez aqui? Cadastre-se agora mesmo abaixo!',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthTextField(
                    controller: nameController,
                    hintText: 'Nome completo',
                    obscureText: false,
                  ),
                  const SizedBox(height: 15),
                  AuthTextField(
                    controller: emailController,
                    hintText: 'E-mail',
                    obscureText: false,
                    validator: FormValidators.validateEmail,
                  ),
                  const SizedBox(height: 15),
                  Dropdown(
                      items: professionalTypes,
                      hintText: 'Selecione sua profissão',
                      controller: professionalTypeController,
                      onChanged: (newValue) {
                        print(newValue);
                      }),
                  const SizedBox(height: 15),
                  AuthTextField(
                    controller: professionalRegisterController,
                    hintText: 'Registro profissional',
                    obscureText: false,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Dropdown(
                          items: estados,
                          hintText: 'Estado',
                          controller: stateController,
                          onChanged: (newValue) {
                            setState(() {
                              stateController.value = newValue;
                              cidades = this
                                  .stateCityProvider
                                  .getCitiesByState(stateController.value!);
                              cityController.value = null;
                            });
                          },
                          padding: 0.0,
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        flex: 3,
                        child: Dropdown(
                          items: cidades,
                          hintText: 'Cidade',
                          controller: cityController,
                          onChanged: (newValue) {
                            setState(() {
                              cityController.value = newValue;
                            });
                          },
                          padding: 0.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  AuthTextField(
                    controller: passwordController,
                    hintText: 'Crie sua senha',
                    obscureText: true,
                    validator: FormValidators.validatePassword,
                  ),
                  SizedBox(height: 15),
                  AuthTextField(
                    controller: passwordConfirmationController,
                    hintText: 'Confirme sua senha',
                    obscureText: true,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return 'As senhas devem ser iguais';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AuthSubmitButton(
                    onTap: () => signUpUser(context),
                    text: 'Cadastrar',
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ja possui uma conta? ',
                        style: TextStyle(color: Colors.grey[800], fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          navigateToLoginPage(context);
                        },
                        child: Text(
                          'Faca login aqui!',
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
        builder: (context) => HomePage(
          name: responseData['name'],
          email: responseData['email'],
          token: responseData['token'],
          onQuit: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
    );
  }

  void navigateToLoginPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  void storeToken(String token) async {
    await secureStorage.write(
      key: 'token',
      value: token,
    );
  }
}
