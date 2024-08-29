import 'package:flutter/material.dart';
import 'package:meu_plantao_front/screens/auth/components/auth_submit_button.dart';
import 'package:meu_plantao_front/screens/auth/components/auth_text_field.dart';
import 'package:meu_plantao_front/screens/auth/components/dropdown.dart';
import 'package:meu_plantao_front/screens/auth/enums/ProfessionalTypeEnum.dart';
import 'package:meu_plantao_front/screens/common/state_city_provider.dart'
    as state_city_provider;
import 'package:meu_plantao_front/service/account_service.dart';
import 'package:meu_plantao_front/screens/common/components/auto_close_dialog.dart';

class AccountPage extends StatefulWidget {
  final Function(String) onNameUpdated;

  AccountPage({required this.onNameUpdated});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final stateCityProvider = state_city_provider.StateCityProvider();
  final AccountService accountService = AccountService();

  final nameController = TextEditingController();
  final professionalRegisterController = TextEditingController();
  final professionalTypeController = ValueNotifier<String?>(null);
  final stateController = ValueNotifier<String?>(null);
  final cityController = ValueNotifier<String?>(null);

  List<String> professionalTypes =
      ProfessionalType.values.map((type) => type.label).toList();
  List<String> estados = [];
  List<String> cidades = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadInitialStateData();
    await _fetchAccountInfo();
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
        _showErrorDialog('Failed to load account information.');
      }
    } catch (e) {
      print('Error fetching account info: $e');
      _showErrorDialog('An error occurred while fetching account information.');
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
      professionalTypeController.value =
          ProfessionalType.values[data['professionalType']].label;
      stateController.value = data['state'];
      cityController.value = data['city'];
      cidades = stateCityProvider.getCitiesByState(stateController.value!);
    });
  }

  Future<void> _handleUpdate() async {
    try {
      await accountService.updateAccountInfo(
        name: nameController.text,
        professionalRegister: professionalRegisterController.text,
        professionalType: professionalTypeController.value!,
        state: stateController.value!,
        city: cityController.value!,
      );
      AutoCloseDialog.show(context, 'Informações atualizadas com sucesso');
      widget.onNameUpdated(nameController.text);
    } catch (e) {
      print('Error updating account info: $e');
      _showErrorDialog('An error occurred while updating account information.');
    }
  }

  void _showErrorDialog(String message) {
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
      return Scaffold(
        appBar: AppBar(title: const Text('Minha Conta')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Minha Conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildNameField(),
              const SizedBox(height: 15),
              _buildProfessionalTypeDropdown(),
              const SizedBox(height: 15),
              _buildProfessionalRegisterField(),
              const SizedBox(height: 15),
              _buildLocationFields(),
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

  Widget _buildNameField() {
    return AuthTextField(
      controller: nameController,
      hintText: 'Nome completo',
      obscureText: false,
    );
  }

  Widget _buildProfessionalTypeDropdown() {
    return Dropdown(
      items: professionalTypes,
      hintText: 'Selecione sua profissão',
      controller: professionalTypeController,
      onChanged: (newValue) {
        setState(() {
          professionalTypeController.value = newValue;
        });
      },
    );
  }

  Widget _buildProfessionalRegisterField() {
    return AuthTextField(
      controller: professionalRegisterController,
      hintText: 'Registro profissional',
      obscureText: false,
    );
  }

  Widget _buildLocationFields() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Dropdown(
            items: estados,
            hintText: 'Estado',
            controller: stateController,
            onChanged: (newValue) {
              setState(() {
                stateController.value = newValue;
                cidades =
                    stateCityProvider.getCitiesByState(stateController.value!);
                cityController.value = null;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
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
          ),
        ),
      ],
    );
  }
}
