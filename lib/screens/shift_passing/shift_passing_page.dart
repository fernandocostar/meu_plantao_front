import 'dart:math';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:meu_plantao_front/screens/shift_passing/components/shiftpass_submit_button.dart';
import 'package:meu_plantao_front/service/shift_service.dart';
import 'package:meu_plantao_front/service/shiftpass_service.dart';
import 'package:meu_plantao_front/service/account_service.dart';
import 'package:meu_plantao_front/screens/common/components/auto_close_dialog.dart';
import 'package:meu_plantao_front/screens/shift_passing/components/shift_detail_card.dart';

class ShiftPassingPage extends StatefulWidget {
  final Map<String, dynamic> shift;
  final VoidCallback onSave;
  Map<String, dynamic> shiftPass;

  ShiftPassingPage({
    required this.shift,
    required this.onSave,
    this.shiftPass = const {},
  });

  @override
  _ShiftPassingPageState createState() => _ShiftPassingPageState();
}

class _ShiftPassingPageState extends State<ShiftPassingPage> {
  final ShiftService _shiftService = ShiftService();
  final ShiftPassService _shiftPassService = ShiftPassService();
  final AccountService _accountService = AccountService();
  List<Map<String, dynamic>> _assignedUsers = [];
  Map<String, dynamic>? _createdBy;
  bool _isSaving = false;
  bool _isExistingPassage = false;

  // Constants for styling
  static const double _padding = 16.0;
  static const double _buttonPadding = 15.0;
  static const double _dialogPadding = 20.0;
  static const double _fontSize = 18.0;
  static const double _buttonFontSize = 14.0;
  static const double _borderRadius = 8.0;
  static const Color _primaryColor =
      Color.fromARGB(255, 32, 184, 86); // Colors.green
  static const Color _secondaryColor = Color(0xFFBDBDBD); // Colors.grey[400]
  static const Color _whiteColor = Color(0xFFFFFFFF); // Colors.white
  static const Color _blackColor = Color(0xFF000000); // Colors.black

  @override
  void initState() {
    super.initState();
    _checkExistingPassage();
  }

  Future<void> _checkExistingPassage() async {
    try {
      // Verificar se a passagem já existe e obter os detalhes da passagem
      Map<String, dynamic> shiftPassDetails =
          await _shiftPassService.shiftPassExists(widget.shift['id']);

      setState(() {
        if (shiftPassDetails.isNotEmpty) {
          _isExistingPassage = true;
          widget.shiftPass =
              shiftPassDetails; // Armazena os detalhes do shift pass
        } else {
          _isExistingPassage = false;
        }
      });

      if (_isExistingPassage) {
        _loadExistingAssignedUsers(
            shiftPassDetails['id']); // Passa o shiftPassId correto
      }
    } catch (e) {
      AutoCloseDialog.show(context, 'Falha ao verificar passagem existente.');
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _loadExistingAssignedUsers(int shiftPassId) async {
    try {
      // Requisição para buscar os offeredUsers
      Map<String, dynamic> shiftPassDetails =
          await _shiftPassService.fetchOfferedUsers(shiftPassId);

      setState(() {
        // Armazenando o createdBy
        _createdBy = shiftPassDetails['createdBy'];

        // Armazenando os offeredUsers como uma lista de mapas
        _assignedUsers = List<Map<String, dynamic>>.from(
          shiftPassDetails['offeredUsers'].map<Map<String, dynamic>>((user) {
            return {
              'id': user['id'] ??
                  0, // Usar 0 ou outro valor padrão se o id for null
              'name': user['name'] ?? 'Nome não informado',
              'email': user['email'] ?? 'Email não informado',
            };
          }).toList(),
        );
      });
    } catch (e) {
      AutoCloseDialog.show(
          context, 'Falha ao carregar plantonistas atribuídos. $e');
    }
  }

  void _showAddPlantonistaDialog() {
    final TextEditingController _phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Plantonista'),
          content: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Número de Celular',
              hintText: 'Ex: 11987654321',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                String phoneNumber = _phoneController.text.trim();
                if (phoneNumber.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Por favor, insira um número de celular.')),
                  );
                  return;
                }

                try {
                  Map<String, dynamic>? user =
                      await _accountService.searchUserByPhone(phoneNumber);
                  if (user != null) {
                    setState(() {
                      _assignedUsers.add({
                        'id': user['id'],
                        'name': user['name'],
                        'phone': user['phone'],
                      });
                    });
                    Navigator.of(context).pop(); // Fechar o popup
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Nenhum usuário encontrado com esse número.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao buscar usuário: $e')),
                  );
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePassing() async {
    if (_assignedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Adicione pelo menos um plantonista para passar o plantão.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      List<String> userIds =
          _assignedUsers.map((user) => user['id'] as String).toList();

      if (_isExistingPassage) {
        await _shiftPassService.editShiftPass(
          shiftPassId: widget.shift['id'],
          offeredUsers: userIds,
        );
        AutoCloseDialog.show(
            context, 'Passagem de plantão atualizada com sucesso!');
      } else {
        await _shiftPassService.createShiftPass(
          shiftId: widget.shift['id'],
          offeredUsers: userIds,
        );
        AutoCloseDialog.show(
            context, 'Passagem de plantão criada com sucesso!');
      }
      widget.onSave();
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar passagem: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passar Plantão'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(_padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detalhes do plantão
              ShiftDetailsCard(
                shift: widget.shift,
                primaryColor: _primaryColor,
              ),
              const SizedBox(height: _padding),

              // Lista de Plantonistas Adicionados
              const Text(
                'Oferecido a:',
                style:
                    TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              _assignedUsers.isEmpty
                  ? const Text('Nenhum plantonista adicionado.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _assignedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _assignedUsers[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text('${user['name']}'),
                          subtitle: Text('${user['email']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _assignedUsers.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
              const SizedBox(height: _padding),

              // Botão de Adicionar Plantonista
              Center(
                child: ElevatedButton.icon(
                  onPressed: _showAddPlantonistaDialog,
                  icon: const Icon(
                    Icons.add,
                    color: _whiteColor,
                  ),
                  label: const Text(
                    'Adicionar Plantonista',
                    style: TextStyle(color: _whiteColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: _buttonPadding,
                        vertical: _buttonPadding / 2),
                    backgroundColor: const Color.fromARGB(255, 58, 77, 176),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _padding),

              // Botão de Salvar Passagem
              ShiftPassSubmitButton(
                buttonText: 'Salvar Passagem',
                isButtonEnabled: !_isSaving,
                onPressed: _isSaving ? null : _savePassing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
