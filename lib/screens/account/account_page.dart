import 'package:flutter/material.dart';
import 'package:meu_plantao_front/screens/auth/components/auth_submit_button.dart';
import 'package:meu_plantao_front/screens/auth/components/auth_text_field.dart';
import 'package:meu_plantao_front/screens/auth/components/dropdown.dart';
import 'package:meu_plantao_front/screens/auth/enums/ProfessionalTypeEnum.dart';
import 'package:meu_plantao_front/screens/common/state_city_provider.dart'
    as state_city_provider;
import 'package:meu_plantao_front/service/account_service.dart';
import 'package:meu_plantao_front/screens/common/components/auto_close_dialog.dart'; // Import your AutoCloseDialog

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final stateCityProvider = state_city_provider.StateCityProvider();
  final AccountService accountService = AccountService();

  final nameController = TextEditingController();
  final professionalRegisterController = TextEditingController();
  ValueNotifier<String?> professionalTypeController =
      ValueNotifier<String?>(null);
  ValueNotifier<String?> stateController = ValueNotifier<String?>(null);
  ValueNotifier<String?> cityController = ValueNotifier<String?>(null);

  List<String> professionalTypes =
      ProfessionalType.values.map((type) => type.label).toList();
  List<String> estados = [];
  List<String> cidades = [];

  @override
  void initState() {
    super.initState();
    loadInitialStateData();
    fetchAccountInfo();
  }

  Future<void> loadInitialStateData() async {
    await stateCityProvider.loadStateAndCityData();
    setState(() {
      estados = stateCityProvider.getStateNames();
    });
  }

  Future<void> fetchAccountInfo() async {
    try {
      final data = await accountService.fetchAccountInfo();

      if (data != null) {
        setState(() {
          nameController.text = data['name'];
          professionalRegisterController.text = data['professionalRegister'];
          professionalTypeController.value =
              ProfessionalType.values[data['professionalType']].label;
          stateController.value = data['state'];
          cityController.value = data['city'];
          cidades = stateCityProvider.getCitiesByState(stateController.value!);
        });
      } else {
        _showErrorDialog('Failed to load account information.');
      }
    } catch (e) {
      print('Error fetching account info: $e');
      _showErrorDialog('An error occurred while fetching account information.');
    }
  }

  Future<void> _handleUpdate(BuildContext context) async {
    try {
      await accountService.updateAccountInfo(
        name: nameController.text,
        professionalRegister: professionalRegisterController.text,
        professionalType: professionalTypeController.value!,
        state: stateController.value!,
        city: cityController.value!,
      );

      // Show the auto-close dialog with success message
      AutoCloseDialog.show(context, 'Informações atualizadas com sucesso');

      // Optionally, navigate back or update UI if needed
      // Navigator.pop(context); // Uncomment if you want to go back after updating
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Conta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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
                  onChanged: (newValue) {
                    setState(() {
                      professionalTypeController.value = newValue;
                    });
                  },
                ),
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
                            cidades = stateCityProvider
                                .getCitiesByState(stateController.value!);
                            cityController.value = null;
                          });
                        },
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AuthSubmitButton(
                  onTap: () => _handleUpdate(context),
                  text: 'Atualizar Informações',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
