import 'package:flutter/material.dart';
import 'package:meu_plantao_front/screens/manage_locations/edit_location_page.dart';
import 'create_location_page.dart';
import '../../service/location_service.dart';
import '../common/components/auto_close_dialog.dart';

class ManageLocationsPage extends StatefulWidget {
  final VoidCallback onLocationsUpdated;

  ManageLocationsPage({required this.onLocationsUpdated});

  @override
  _ManageLocationsPageState createState() => _ManageLocationsPageState();
}

class _ManageLocationsPageState extends State<ManageLocationsPage> {
  final LocationService _locationService = LocationService();
  final Color primaryColor = Colors.green;
  List<Map<String, dynamic>> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<dynamic> locationsData = await _locationService.fetchAllActiveLocations();
      setState(() {
        _locations = locationsData.map((location) {
          return {
            'id': location['id'].toString(),
            'name': location['name'],
          };
        }).toList();
      });
      widget.onLocationsUpdated();
    } catch (e) {
      print("Failed to load locations: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao carregar locais. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleEditLocation(Map<String, dynamic> location) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final controller = TextEditingController(text: location['name']);
        return AlertDialog(
          title: Text('Editar Local'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nome do Local'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final updatedName = controller.text;
                _locationService.updateLocation(id: location['id'], name: updatedName);
                Navigator.of(context).pop(updatedName);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        location['name'] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Locais'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(backgroundColor: primaryColor))
          : ListView.builder(
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                      title: Text(location['name'], style: TextStyle(fontSize: 16)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.grey),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditLocationPage(
                                    onLocationsCreated: _loadLocations,
                                    location: location,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.grey),
                            onPressed: () => _showDeleteConfirmationDialog(context, location),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      indent: 15.0,
                      endIndent: 15.0,
                      color: Colors.grey.shade300,
                      height: 1,
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLocationPage(onLocationsCreated: _loadLocations),
            ),
          );

          if (result != null) {
            _loadLocations();
          }
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: primaryColor,
        tooltip: 'Adicionar Local',
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Confirmar Exclusão",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Tem certeza que deseja excluir esse local?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _deleteLocation(location);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      child: Text(
                        "Deletar",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteLocation(Map<String, dynamic> location) async {
    try {
      await _locationService.deleteLocation(location['id']);
      setState(() {
        _locations.remove(location);
      });
      _loadLocations();
      AutoCloseDialog.show(context, 'Local deletado com sucesso');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao deletar local. Tente novamente. $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
