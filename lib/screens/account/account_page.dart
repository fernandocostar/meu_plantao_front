import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:meu_plantao_front/screens/auth/components/auth_submit_button.dart';
import 'package:meu_plantao_front/screens/auth/components/auth_text_field.dart';
import 'package:meu_plantao_front/screens/auth/components/dropdown.dart';
import 'package:meu_plantao_front/screens/auth/enums/ProfessionalTypeEnum.dart';
import 'package:meu_plantao_front/screens/common/state_city_provider.dart' as state_city_provider;
import 'package:meu_plantao_front/service/account_service.dart';
import 'package:meu_plantao_front/screens/common/components/auto_close_dialog.dart';
import 'package:meu_plantao_front/screens/account/account_page_validators.dart';

class AccountPage extends StatefulWidget {
  static const String failedToUpdateAccountInfo = 'Falha ao recuperar informações da conta.';
  static const String successUpdatingAccountInfo = 'Informações atualizadas com sucesso.';

  final Function(String) onNameUpdated;

  const AccountPage({required this.onNameUpdated});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final stateCityProvider = state_city_provider.StateCityProvider();
  late final AccountService accountService = AccountService();

  final nameController = TextEditingController();
  final professionalRegisterController = TextEditingController();
  final professionalTypeController = ValueNotifier<String?>(null);
  final stateController = ValueNotifier<String?>(null);
  final cityController = ValueNotifier<String?>(null);

  List<String> professionalTypes = ProfessionalType.values.map((type) => type.label).toList();
  List<String> estados = [];
  List<String> cidades = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([_loadInitialStateData(), _fetchAccountInfo()]);
  }

  Future<void> _loadInitialStateData() async {
    await stateCityProvider.loadStateAndCityData();
    setState(() {
      estados = stateCityProvider.getStateNames();
    });
  }

  Future<void> _fetchAccountInfo() async {
    try {
      final data = await accountService.fetchAccountInfo();
      if (data != null) {
        _updateUIWithAccountInfo(data);
      } else {
        _showErrorDialog(AccountPage.failedToUpdateAccountInfo);
      }
    } catch (e) {
      log('Error fetching account info: $e');
      _showErrorDialog(AccountPage.failedToUpdateAccountInfo);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateUIWithAccountInfo(Map<String, dynamic> data) {
    setState(() {
      nameController.text = data['name'];
      professionalRegisterController.text = data['professionalRegister'];
      professionalTypeController.value = ProfessionalType.values[data['professionalType']].label;
      stateController.value = data['state'];
      cityController.value = data['city'];
      cidades = stateCityProvider.getCitiesByState(stateController.value!);
    });
  }

  Future<void> _handleUpdate() async {
    // Perform validation using the validators
    final nameError = AccountPageValidators.validateName(nameController.text);
    final registerError = AccountPageValidators.validateProfessionalRegister(professionalRegisterController.text);

    if (nameError != null || registerError != null) {
      _showErrorDialog(nameError ?? registerError!);
      return;
    }

    // If validation passes, proceed to update account info
    try {
      await accountService.updateAccountInfo(
        name: nameController.text,
        professionalRegister: professionalRegisterController.text,
        professionalType: professionalTypeController.value!,
        state: stateController.value!,
        city: cityController.value!,
      );
      AutoCloseDialog.show(context, AccountPage.successUpdatingAccountInfo);
      widget.onNameUpdated(nameController.text);
    } catch (e) {
      log('Error updating account info: $e');
      _showErrorDialog(AccountPage.failedToUpdateAccountInfo);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => ErrorDialog(message: message),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    professionalRegisterController.dispose();
    professionalTypeController.dispose();
    stateController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Minha Conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              AuthTextField(
                controller: nameController,
                hintText: 'Nome completo',
                obscureText: false,
              ),
              const SizedBox(height: 15),
              Dropdown(
                items: professionalTypes,
                hintText: 'Selecione sua profissão',
                controller: professionalTypeController,
              ),
              const SizedBox(height: 15),
              AuthTextField(
                controller: professionalRegisterController,
                hintText: 'Registro profissional',
                obscureText: false,
              ),
              const SizedBox(height: 15),
              LocationFields(
                estados: estados,
                cidades: cidades,
                stateController: stateController,
                cityController: cityController,
                onStateChanged: (value) {
                  setState(() {
                    cidades = stateCityProvider.getCitiesByState(value!);
                    cityController.value = null;
                  });
                },
              ),
              const SizedBox(height: 20),
              AuthSubmitButton(
                onTap: _handleUpdate,
                text: 'Atualizar Informações',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Conta')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class LocationFields extends StatelessWidget {
  final List<String> estados;
  final List<String> cidades;
  final ValueNotifier<String?> stateController;
  final ValueNotifier<String?> cityController;
  final Function(String?) onStateChanged;

  const LocationFields({
    required this.estados,
    required this.cidades,
    required this.stateController,
    required this.cityController,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Dropdown(
          items: estados,
          hintText: 'Selecione seu estado',
          controller: stateController,
          onChanged: onStateChanged,
        ),
        const SizedBox(height: 15),
        Dropdown(
          items: cidades,
          hintText: 'Selecione sua cidade',
          controller: cityController,
        ),
      ],
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final String message;

  const ErrorDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Erro'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}