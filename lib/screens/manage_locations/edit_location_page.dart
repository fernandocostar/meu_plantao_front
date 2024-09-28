import 'package:flutter/material.dart';
import 'package:meu_plantao_front/service/location_service.dart';

class EditLocationPage extends StatefulWidget {

final Map<String, dynamic> location;
final VoidCallback onLocationsCreated; // Add this callback

EditLocationPage({required this.onLocationsCreated, required this.location}); // Initialize it in the constructor

  @override
  _EditLocationPageState createState() => _EditLocationPageState();
}

class _EditLocationPageState extends State<EditLocationPage> {
  final LocationService _locationService = LocationService();
  final TextEditingController _nameController = TextEditingController();
  final Color primaryColor = Colors.green; // Primary color for the page
  bool _isLoading = false; // Track loading state

@override
  void initState() {    
    super.initState();
    _nameController.text = widget.location['name']; // Initialize the name field
  }

  void _editLocation() async {
    String name = _nameController.text;
    if (name.isNotEmpty) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      try {
        await _locationService.updateLocation(id: widget.location['id'], name: _nameController.text);
        widget.onLocationsCreated();
        Navigator.of(context).pop(true);
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar local: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nome do local não pode ser vazio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar local'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNameField(),
              const SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator()) // Show loading indicator
                  : _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      obscureText: false,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Colors.grey.shade800),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Colors.grey.shade100,
        filled: true,
        hintText: 'Digite o nome do local',
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      style: TextStyle(color: Colors.grey.shade900),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: _editLocation,
      onHighlightChanged: (isHighlighted) {
        setState(() {
          // This can be used to change the button's appearance on press
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Salvar alterações',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
